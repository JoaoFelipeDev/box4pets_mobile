// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'tracos_doencas_bloc.dart';

@immutable
abstract class TracosDoencasState {}

class TracosDoencasInitial extends TracosDoencasState {}

class TracosDoencasLoading extends TracosDoencasState {}

class TracosDoencasLoaded extends TracosDoencasState {
  final AppResultadoResumoModel tracosDoencas;
  TracosDoencasLoaded({
    required this.tracosDoencas,
  });
}
