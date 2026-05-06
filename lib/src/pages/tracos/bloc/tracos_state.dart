// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'tracos_bloc.dart';

@immutable
abstract class TracosState {}

final class TracosInitial extends TracosState {}

final class TracosLoading extends TracosState {}

class TracosLoaded extends TracosState {
  final List<TracosModel> tracos;
  final List<String> categorias;
  TracosLoaded({
    required this.tracos,
    required this.categorias,
  });
}
