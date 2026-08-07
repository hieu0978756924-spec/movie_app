import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/services/preference_service.dart';
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
  const RegisterSubmittedEvent(this.email, this.password);
  @override
  List<Object?> get props => [email, password];
}

class ResetPasswordSubmittedEvent extends AuthEvent {
  final String email;
  const ResetPasswordSubmittedEvent(this.email);
  @override
  List<Object?> get props => [email];
}

class DemoLoginSubmittedEvent extends AuthEvent {}

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
    on<DemoLoginSubmittedEvent>(_onDemoLoginSubmitted);
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
    result.fold(
      (failure) => emit(AuthErrorState(failure.message)),
      (response) {
        if (response.user != null) {
          emit(AuthenticatedState(response.user!));
        } else {
          emit(const AuthErrorState('User object is null after login'));
        }
      },
    );
  }

  Future<void> _onRegisterSubmitted(
      RegisterSubmittedEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());
    final result = await registerUseCase(event.email, event.password);
    result.fold(
      (failure) => emit(AuthErrorState(failure.message)),
      (response) {
        if (response.user != null) {
          emit(AuthenticatedState(response.user!));
        } else {
          emit(const AuthErrorState(
              'Đăng ký thành công. Vui lòng kiểm tra email để xác thực.'));
        }
      },
    );
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

  Future<void> _onDemoLoginSubmitted(
      DemoLoginSubmittedEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());
    await PreferenceService.saveLogin(true);
    AppRouter.setDemoLoggedIn(true);

    const demoUser = User(
      id: 'demo-user-id',
      appMetadata: {},
      userMetadata: {'full_name': 'Khách Trải Nghiệm'},
      aud: 'authenticated',
      createdAt: '2026-01-01T00:00:00.000Z',
      email: 'demo@gocphim.com',
    );
    emit(const AuthenticatedState(demoUser));
  }
}

