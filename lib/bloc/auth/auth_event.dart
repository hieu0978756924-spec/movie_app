import 'package:equatable/equatable.dart';

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

