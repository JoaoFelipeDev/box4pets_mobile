// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'doencas_uma_variante_bloc.dart';

@immutable
sealed class DoencasUmaVarianteEvent {}

class DoencasUmaVarianteGetEvent extends DoencasUmaVarianteEvent {
  final List<String> id;
  final String especie;
  DoencasUmaVarianteGetEvent({
    required this.id,
    required this.especie
  });
}
