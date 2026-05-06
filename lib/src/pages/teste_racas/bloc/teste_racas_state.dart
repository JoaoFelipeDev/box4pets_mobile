// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'teste_racas_bloc.dart';

@immutable
sealed class TesteRacasState {}

final class TesteRacasInitial extends TesteRacasState {}

final class TesteRacasLoading extends TesteRacasState {}

class TesteRacasLoaded extends TesteRacasState {
  final List<RacasModel> racas;
  final List<AppResultadoRacaModel> resuldado;
  TesteRacasLoaded({
    required this.racas,
    required this.resuldado,
  });
}
