// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'activation_bloc.dart';

@immutable
sealed class ActivationState {}

final class ActivationInitial extends ActivationState {}

final class ActivationLoading extends ActivationState {}

final class ActivationLoaded extends ActivationState {}

class ActivationError extends ActivationState {
  final String message;
  ActivationError({
    required this.message,
  });
}

class ActivationRacasLoaded extends ActivationState {
  final List<RacasModel> racasDog;
  final List<RacasModel> racasCat;
  ActivationRacasLoaded({
    required this.racasDog,
    required this.racasCat,
  });
}
