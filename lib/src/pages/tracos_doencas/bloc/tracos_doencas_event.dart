// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'tracos_doencas_bloc.dart';

@immutable
abstract class TracosDoencasEvent {}

class TracosDoencasGetEvent extends TracosDoencasEvent {
  final String box;
  TracosDoencasGetEvent({
    required this.box,
  });
}
