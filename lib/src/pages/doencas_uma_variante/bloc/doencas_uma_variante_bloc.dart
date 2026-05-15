import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:Box4Pets/src/pages/doencas_uma_variante/repositories/app_lista_doenca_repository.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import '../models/app_lista_doencas_model.dart';

part 'doencas_uma_variante_event.dart';
part 'doencas_uma_variante_state.dart';
List <String> _categorias = ['Odontológico', 'Oftalmológico', 'Neurológico', 'Imunológico', 'Endócrino', 'Ossos e Músculos', 'Renal', 'Metabólico', 'Hematológico', 'Dermatológico', 'Reprodutivo', 'Gastrointestinal e Hepático', 'Cardio Respiratório', 'Oncológico', 'Audição',];
class DoencasUmaVarianteBloc
    extends Bloc<DoencasUmaVarianteEvent, DoencasUmaVarianteState> {
  final appListaDoencaRepository = AppListaDoencaRepository();
  DoencasUmaVarianteBloc() : super(DoencasUmaVarianteInitial()) {
    on<DoencasUmaVarianteEvent>((event, emit) async {
      if (event is DoencasUmaVarianteGetEvent) {
        final List<AppListaDoencasModel> doenca = [];
        final List<String> categorias = [];
        final List<String> listId = event.id;

        emit(DoencasUmaVarianteLoading(current: 0, total: listId.length));

        for (int i = 0; i < listId.length; i++) {
          final element = listId[i];
          final response = await appListaDoencaRepository
              .getListaDoenca(id: element, especies: event.especie);

          final map = response.data['records'][0]['fields'];
          if (!categorias.contains(map['Categoria'])) {
            categorias.add(map['Categoria']);
          }
          doenca.add(AppListaDoencasModel.fromMap(map));

          emit(DoencasUmaVarianteLoading(
              current: i + 1, total: listId.length));
        }
        emit(DoencasUmaVarianteLoaded(doenca: doenca, categorias: categorias));
      }
    });
  }
}
