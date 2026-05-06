// ignore_for_file: public_member_api_docs, sort_constructors_first, must_be_immutable
part of 'auth_bloc_bloc.dart';

@immutable
sealed class AuthBlocState {}

final class AuthBlocInitial extends AuthBlocState {}

final class AuthBlocLoading extends AuthBlocState {}

class AuthBlocLoaded extends AuthBlocState {
  final bool isAuthenticated;
  AuthBlocLoaded({
    required this.isAuthenticated,
  });
}

class AuthBlocError extends AuthBlocState {
  String messageError;
  AuthBlocError({
    required this.messageError,
  });
}

class AuthBlocForgotPassword extends AuthBlocState {
  final String email;
  final String code;
  AuthBlocForgotPassword({
    required this.email,
    required this.code,
  });
}

class AuthBlocCheckCode extends AuthBlocState {
  final bool isValid;
  AuthBlocCheckCode({
    required this.isValid,
  });
}

class AuthBlocChangePassword extends AuthBlocState {
  final bool isChanged;
  AuthBlocChangePassword({
    required this.isChanged,
  });
}
