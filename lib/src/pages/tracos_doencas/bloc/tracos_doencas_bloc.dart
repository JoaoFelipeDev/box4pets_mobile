import 'package:bloc/bloc.dart';
import 'package:Box4Pets/src/pages/tracos_doencas/repositories/tracos_doencas_repository.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import '../models/app_resultado_resumo_model.dart';

part 'tracos_doencas_event.dart';
part 'tracos_doencas_state.dart';

class TracosDoencasBloc extends Bloc<TracosDoencasEvent, TracosDoencasState> {
  final tracosDoencasRepository = TracosDoencasRepository();
  TracosDoencasBloc() : super(TracosDoencasInitial()) {
    on<TracosDoencasEvent>((event, emit) async {
      emit(TracosDoencasLoading());

      if (event is TracosDoencasGetEvent) {
        print('Box: ${event.box}');
        final Response<dynamic> response =
            await tracosDoencasRepository.getTracosDoencas(box: event.box);

        if (response.statusCode == 200) {
          Map<String, dynamic> map = response.data['records'][0];

          final AppResultadoResumoModel doenca =
              AppResultadoResumoModel.fromMap(map);

          emit(TracosDoencasLoaded(tracosDoencas: doenca));
        }
      }
    });
  }
}
