import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthStarted extends AuthEvent {}

class SignInRequested extends AuthEvent {
  final String phoneNumber;
  final String password;

  const SignInRequested({
    required this.phoneNumber,
    required this.password,
  });

  @override
  List<Object> get props => [phoneNumber, password];
}

class SignUpRequested extends AuthEvent {
  final String phoneNumber;
  final String password;
  final String firstName;
  final String lastName;

  const SignUpRequested({
    required this.phoneNumber,
    required this.password,
    required this.firstName,
    required this.lastName,
  });

  @override
  List<Object> get props => [phoneNumber, password, firstName, lastName];
}

class SignOutRequested extends AuthEvent {}
