import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/di/injection.dart';
import '../../../home/controllers/home_controller.dart';
import '../../../profile/data/user_profile_manager.dart';
import '../../../profile/data/watch_history_manager.dart';
import '../../../review/data/datasources/user_review_manager.dart';
import '../../../watchlist/data/datasources/watchlist_local_datasource.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class CheckAuthEvent extends AuthEvent {}

class LoginSubmittedEvent extends AuthEvent {
  final String email;
  final String password;
  const LoginSubmittedEvent(this.email, this.password);
  @override
  List<Object?> get props => [email, password];
}

class RegisterSubmittedEvent extends AuthEvent {
  final String email;
  final String password;
  final String? name;
  final String? dob;
  const RegisterSubmittedEvent(this.email, this.password, {this.name, this.dob});
  @override
  List<Object?> get props => [email, password, name, dob];
}

class ResetPasswordSubmittedEvent extends AuthEvent {
  final String email;
  const ResetPasswordSubmittedEvent(this.email);
  @override
  List<Object?> get props => [email];
}

// States
abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitialState extends AuthState {}

class AuthLoadingState extends AuthState {}

class AuthenticatedState extends AuthState {
  final User user;
  const AuthenticatedState(this.user);
  @override
  List<Object?> get props => [user];
}

class UnauthenticatedState extends AuthState {}

class ResetPasswordSuccessState extends AuthState {
  final String message;
  const ResetPasswordSuccessState(
      [this.message = 'Vui lòng kiểm tra email của bạn để đặt lại mật khẩu']);
  @override
  List<Object?> get props => [message];
}

class RegisterSuccessState extends AuthState {
  final String message;
  const RegisterSuccessState(
      [this.message = 'Đăng ký tài khoản thành công! Vui lòng đăng nhập để tiếp tục.']);
  @override
  List<Object?> get props => [message];
}

class AuthErrorState extends AuthState {
  final String message;
  const AuthErrorState(this.message);
  @override
  List<Object?> get props => [message];
}

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;

  AuthBloc(
    this.loginUseCase,
    this.registerUseCase,
    this.resetPasswordUseCase,
    this.getCurrentUserUseCase,
  ) : super(AuthInitialState()) {
    on<CheckAuthEvent>(_onCheckAuth);
    on<LoginSubmittedEvent>(_onLoginSubmitted);
    on<RegisterSubmittedEvent>(_onRegisterSubmitted);
    on<ResetPasswordSubmittedEvent>(_onResetPasswordSubmitted);
  }

  void _onCheckAuth(CheckAuthEvent event, Emitter<AuthState> emit) {
    final user = getCurrentUserUseCase();
    if (user != null) {
      emit(AuthenticatedState(user));
    } else {
      emit(UnauthenticatedState());
    }
  }


  Future<void> _onLoginSubmitted(
      LoginSubmittedEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());
    final result = await loginUseCase(event.email, event.password);
    await result.fold(
      (failure) async {
        if (!emit.isDone) {
          emit(AuthErrorState(failure.message));
        }
      },
      (response) async {
        if (response.user != null) {
          final loggedEmail = response.user!.email ?? event.email;
          final metaName = response.user!.userMetadata?['name'] ?? response.user!.userMetadata?['full_name'];
          final nameToUse = (metaName != null && metaName.toString().isNotEmpty)
              ? metaName.toString()
              : null;

          await Future.wait([
            WatchHistoryManager.instance.loadForUser(loggedEmail),
            UserReviewManager.instance.loadForUser(loggedEmail),
            HomeController.instance.loadForUser(loggedEmail),
            UserProfileManager.instance.loadProfile(loggedEmail),
          ]);
          UserProfileManager.instance.fetchReviewCount();

          if (!emit.isDone) {
            emit(AuthenticatedState(response.user!));
          }
        } else {
          if (!emit.isDone) {
            emit(const AuthErrorState('User object is null after login'));
          }
        }
      },
    );
  }

  Future<void> _onRegisterSubmitted(
      RegisterSubmittedEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());
    try {
      final result = await registerUseCase(event.email, event.password)
          .timeout(const Duration(seconds: 10));
      await result.fold(
        (failure) async {
          if (!emit.isDone) {
            emit(AuthErrorState(failure.message));
          }
        },
        (response) async {
          try {
            await Supabase.instance.client.auth.signOut().timeout(
                  const Duration(seconds: 3),
                  onTimeout: () {},
                );
          } catch (_) {}

          WatchHistoryManager.instance.clearHistory();
          UserReviewManager.instance.clearReviews();
          HomeController.instance.clearFavorites();
          try {
            getIt<WatchlistLocalDataSource>().clearWatchlist();
          } catch (_) {}
          UserProfileManager.instance.resetForUser(
            email: event.email,
            name: (event.name != null && event.name!.isNotEmpty) ? event.name : null,
            dob: (event.dob != null && event.dob!.isNotEmpty) ? event.dob : null,
          );
          await WatchHistoryManager.instance.loadForUser(event.email);
          await UserReviewManager.instance.loadForUser(event.email);
          await HomeController.instance.loadForUser(event.email);

          if (!emit.isDone) {
            emit(const RegisterSuccessState());
          }
        },

      );
    } on TimeoutException {
      if (!emit.isDone) {
        emit(const AuthErrorState('Quá thời gian kết nối (Timeout). Vui lòng thử lại!'));
      }
    } catch (e) {
      if (!emit.isDone) {
        emit(AuthErrorState('Đã xảy ra lỗi: ${e.toString()}'));
      }
    }
  }

  Future<void> _onResetPasswordSubmitted(
      ResetPasswordSubmittedEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());
    final result = await resetPasswordUseCase(event.email);
    result.fold(
      (failure) => emit(AuthErrorState(failure.message)),
      (_) => emit(const ResetPasswordSuccessState()),
    );
  }
}

