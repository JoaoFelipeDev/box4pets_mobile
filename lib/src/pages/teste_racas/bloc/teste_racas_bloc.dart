import 'package:bloc/bloc.dart';
import 'package:Box4Pets/src/pages/teste_racas/repositories/app_resultado_racas_repository.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import '../models/app_resultado_raca_model.dart';
import '../models/racas_model.dart';

part 'teste_racas_event.dart';
part 'teste_racas_state.dart';

class TesteRacasBloc extends Bloc<TesteRacasEvent, TesteRacasState> {
  final appResultadoRacasRepository = AppResultadoRacasRepository();
  TesteRacasBloc() : super(TesteRacasInitial()) {
    on<TesteRacasEvent>((event, emit) async {
      emit(TesteRacasLoading());

      if (event is TesteRacasGetAppResultadoRacasEvent) {
        List<RacasModel> listRacas = [];
        List<AppResultadoRacaModel> listResultado = [];
        final Response<dynamic> response =
            await appResultadoRacasRepository.getResultadoRacas(id: event.id);
        if (response.statusCode == 200) {
          List<dynamic> result = response.data['records'];

          for (var element in result) {
            var porcent = element['fields']['portentagem'];
            var raca = element['fields']['Raça detectada'][0];

            final Response<dynamic> responseRaca =
                await appResultadoRacasRepository.getRacas(id: raca);
            Map<String, dynamic> resultRaca = responseRaca.data;

            RacasModel racaModel = RacasModel.fromMap(resultRaca);
            AppResultadoRacaModel appResult = AppResultadoRacaModel(
                id: element['id'],
                porcent: double.parse(porcent.toString()),
                racas: racaModel.raca);
            listRacas.add(racaModel);
            listResultado.add(appResult);
          }

          emit(TesteRacasLoaded(racas: listRacas, resuldado: listResultado));
        }
      }
    });
  }
}
