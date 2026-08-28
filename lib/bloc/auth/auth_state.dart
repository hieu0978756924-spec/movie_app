import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

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


class RegisterSuccessState extends AuthState {
  final String message;

  const RegisterSuccessState(
      [this.message =
          'Đăng ký tài khoản thành công! Vui lòng đăng nhập để tiếp tục.']);

  @override
  List<Object?> get props => [message];
}

class AuthErrorState extends AuthState {
  final String message;

  const AuthErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
