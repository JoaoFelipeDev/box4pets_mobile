part of 'parentesco_bloc.dart';

@immutable
sealed class ParentescoEvent {}

class CreateParentesco extends ParentescoEvent {
  final ParentescoModel parentesco;

  CreateParentesco(this.parentesco);
}

class GetAtivacoes extends ParentescoEvent {
  final String email;
  GetAtivacoes(this.email);
}

