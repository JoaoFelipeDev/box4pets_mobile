// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'teste_racas_bloc.dart';

sealed class TesteRacasEvent {}

class TesteRacasGetAppResultadoRacasEvent extends TesteRacasEvent {
  String id;
  TesteRacasGetAppResultadoRacasEvent({
    required this.id,
  });
}
