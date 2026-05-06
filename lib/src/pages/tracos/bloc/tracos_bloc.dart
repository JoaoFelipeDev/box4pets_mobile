import 'package:bloc/bloc.dart';
import 'package:Box4Pets/src/pages/tracos/repositories/tracos_repository.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import '../models/tracos_model.dart';

part 'tracos_event.dart';
part 'tracos_state.dart';

class TracosBloc extends Bloc<TracosEvent, TracosState> {
  final tracosRepository = TracosRepository();
  TracosBloc() : super(TracosInitial()) {
    on<TracosEvent>((event, emit) async {
      emit(TracosLoading());

      if (event is TracosGetEvent) {
        List<String> categorias = [];
        final Response<dynamic> response =
            await tracosRepository.getTracos(event.id, event.especie);

        List<dynamic> result = response.data['records'];

        List<TracosModel> tracos =
            result.map<TracosModel>((e) => TracosModel.fromMap(e)).toList();

        for (var element in tracos) {
          if (!categorias.contains(element.categoria)) {
            categorias.add(element.categoria);
          }
        }

        emit(TracosLoaded(tracos: tracos, categorias: categorias));
      }
    });
  }
}
