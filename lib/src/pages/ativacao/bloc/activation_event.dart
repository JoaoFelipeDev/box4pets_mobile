// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'activation_bloc.dart';

@immutable
sealed class ActivationEvent {}

class ActivationGetRacas extends ActivationEvent {}

class ActivationUser extends ActivationEvent {
  final ActivationModel activation;
  ActivationUser({
    required this.activation,
  });
}
