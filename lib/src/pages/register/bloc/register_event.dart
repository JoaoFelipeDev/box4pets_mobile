// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'register_bloc.dart';

@immutable
sealed class RegisterEvent {}

class RegisterEventRegister extends RegisterEvent {
  final RegisterModel register;
  RegisterEventRegister({
    required this.register,
  });
}
