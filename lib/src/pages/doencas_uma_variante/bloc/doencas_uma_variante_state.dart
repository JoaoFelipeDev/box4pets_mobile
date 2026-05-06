// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'doencas_uma_variante_bloc.dart';

@immutable
sealed class DoencasUmaVarianteState {}

class DoencasUmaVarianteInitial extends DoencasUmaVarianteState {}

class DoencasUmaVarianteLoading extends DoencasUmaVarianteState {}

class DoencasUmaVarianteLoaded extends DoencasUmaVarianteState {
  final List<AppListaDoencasModel> doenca;
  final List categorias;
  DoencasUmaVarianteLoaded({
    required this.doenca,
    required this.categorias,
  });
}

class DoencasUmaVarianteError extends DoencasUmaVarianteState {}
