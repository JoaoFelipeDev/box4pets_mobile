// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'app_ativacao_bloc.dart';

@immutable
abstract class AppAtivacaoEvent {}

class AppAtivacaoGetEvent extends AppAtivacaoEvent {}

class AppAtivacaoGetFilterEvent extends AppAtivacaoEvent {
  final String filter;
  AppAtivacaoGetFilterEvent({
    required this.filter,
  });
}

class AppAtivacaoGetFilterNameEvent extends AppAtivacaoEvent {
  final String filter;
  AppAtivacaoGetFilterNameEvent({
    required this.filter,
  });
}

class AppAtivacaoSDownloadPDF extends AppAtivacaoEvent {
  final String id;
  final String name;
  AppAtivacaoSDownloadPDF({
    required this.id,
    required this.name,
  });
}
