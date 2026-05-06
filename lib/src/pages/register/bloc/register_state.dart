// ignore_for_file: public_member_api_docs, sort_constructors_first, must_be_immutable
part of 'register_bloc.dart';

@immutable
sealed class RegisterState {}

final class RegisterInitial extends RegisterState {}

final class RegisterLoading extends RegisterState {}

class RegisterLoaded extends RegisterState {
  bool isRegister;
  RegisterLoaded({
    required this.isRegister,
  });
}

class RegisterError extends RegisterState {
  String messageError;
  RegisterError({
    required this.messageError,
  });
}
