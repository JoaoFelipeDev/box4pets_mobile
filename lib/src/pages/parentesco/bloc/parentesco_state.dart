part of 'parentesco_bloc.dart';

@immutable
sealed class ParentescoState {}

final class ParentescoInitial extends ParentescoState {}

final class ParentescoLoading extends ParentescoState {}

final class ParentescoGetAtivacoesLoaded extends ParentescoState {
  final List<AtivacaoParentescoModel> ativacoes;

  ParentescoGetAtivacoesLoaded(this.ativacoes);
}

final class ParentescoSuccess extends ParentescoState {
  final String message;

  ParentescoSuccess(this.message);
}
