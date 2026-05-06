// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'auth_bloc_bloc.dart';

@immutable
sealed class AuthBlocEvent {}

class AuthEvent extends AuthBlocEvent {
  final AuthModel auth;
  AuthEvent({
    required this.auth,
  });
}

class AuthForgotPasswordEvent extends AuthBlocEvent {
  final String email;
  AuthForgotPasswordEvent({
    required this.email,
  });
}

class AuthCheckCodeEvent extends AuthBlocEvent {
  final String code;
  AuthCheckCodeEvent({
    required this.code,
  });
}

class AuthChangePasswordEvent extends AuthBlocEvent {
  final String password;
  final String code;
  AuthChangePasswordEvent({
    required this.password,
    required this.code,
  });
}
