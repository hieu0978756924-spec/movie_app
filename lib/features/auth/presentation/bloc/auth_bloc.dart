import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';

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

class AuthErrorState extends AuthState {
  final String message;
  const AuthErrorState(this.message);
  @override
  List<Object?> get props => [message];
}

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;

  AuthBloc(
    this.loginUseCase,
    this.getCurrentUserUseCase,
  ) : super(AuthInitialState()) {
    on<CheckAuthEvent>(_onCheckAuth);
    on<LoginSubmittedEvent>(_onLoginSubmitted);
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
}
