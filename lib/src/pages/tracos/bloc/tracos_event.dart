// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'tracos_bloc.dart';

@immutable
abstract class TracosEvent {}

class TracosGetEvent extends TracosEvent {
  final String id;
  final String especie;
  TracosGetEvent({
    required this.id,
    required this.especie,
  });
}
