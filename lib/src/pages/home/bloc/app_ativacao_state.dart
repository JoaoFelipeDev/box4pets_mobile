// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'app_ativacao_bloc.dart';

@immutable
abstract class AppAtivacaoState {}

final class AppAtivacaoInitial extends AppAtivacaoState {}

final class AppAtivacaoLoading extends AppAtivacaoState {}

class AppAtivacaoLoaded extends AppAtivacaoState {
  final List<BlogModel> blog;
  final List<AppAtivacaoModel> appAtivacao;
  final UserActivationModel user;

  AppAtivacaoLoaded({
    required this.blog,
    required this.appAtivacao,
    required this.user,
  });
}

class AppDownloadPDF extends AppAtivacaoState {
final DownloadPDFModel downloadPDFModel;
  AppDownloadPDF({
    required this.downloadPDFModel,
  });
}
