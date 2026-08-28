import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

import '../../core/di/injection.dart';
import '../../features/home/controllers/home_controller.dart';
import '../../features/profile/data/user_profile_manager.dart';
import '../../features/profile/data/watch_history_manager.dart';
import '../../features/review/data/datasources/user_review_manager.dart';
import '../../features/watchlist/data/datasources/watchlist_local_datasource.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

export 'auth_event.dart';
export 'auth_state.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;

  AuthBloc(
    this.loginUseCase,
    this.registerUseCase,
    this.getCurrentUserUseCase,
  ) : super(AuthInitialState()) {
    on<CheckAuthEvent>(_onCheckAuth);
    on<LoginSubmittedEvent>(_onLoginSubmitted);
    on<RegisterSubmittedEvent>(_onRegisterSubmitted);
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
            name: (event.name != null && event.name!.isNotEmpty)
                ? event.name
                : null,
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
        emit(const AuthErrorState(
            'Quá thời gian kết nối (Timeout). Vui lòng thử lại!'));
      }
    } catch (e) {
      if (!emit.isDone) {
        emit(AuthErrorState('Đã xảy ra lỗi: ${e.toString()}'));
      }
    }
  }
}
