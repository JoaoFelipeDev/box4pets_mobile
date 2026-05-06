import 'dart:convert';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:Box4Pets/src/pages/ativacao/repositories/activation_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import '../models/activation_model.dart';
import '../models/racas_model.dart';

part 'activation_event.dart';
part 'activation_state.dart';

class ActivationBloc extends Bloc<ActivationEvent, ActivationState> {
  final activationRepository = ActivationRepository();
  ActivationBloc() : super(ActivationInitial()) {
    on<ActivationEvent>((event, emit) async {
      if (event is ActivationUser) {
        emit(ActivationLoading());
        final Response<dynamic> response =
            await activationRepository.activateAccount(data: event.activation);

        if (response.statusCode == 200) {
          emit(ActivationLoaded());
        } else {}
      } else if (event is ActivationGetRacas) {
         ByteData conteudo_cachorro =  await rootBundle.load('assets/json/data_racas_cao.json');
         ByteData conteudo_gato =  await rootBundle.load('assets/json/data_raca_gato.json');
          List<dynamic> list_cachorro = json.decode(Utf8Decoder().convert(conteudo_cachorro.buffer.asUint8List()));
          List<dynamic> list_gato = json.decode(Utf8Decoder().convert(conteudo_gato.buffer.asUint8List()));
        emit(ActivationLoading());
        final Response<dynamic> response =
            await activationRepository.getRacas();
        final Response<dynamic> responseCat =
            await activationRepository.getRacasGato();

        if (response.statusCode == 200 && responseCat.statusCode == 200) {
          List<dynamic> listResponse = response.data['records'];
          List<RacasModel> racasDog =
              list_cachorro.map((e) => RacasModel.fromMap(e)).toList();
          racasDog.sort(
            (RacasModel a, RacasModel b) => a.racas.compareTo(b.racas),
          );
          List<dynamic> listResponseCat = responseCat.data['records'];
          List<RacasModel> racasCat =
              list_gato.map((e) => RacasModel.fromMap(e)).toList();
          racasCat.sort(
            (RacasModel a, RacasModel b) => a.racas.compareTo(b.racas),
          );
          emit(ActivationRacasLoaded(racasDog: racasDog, racasCat: racasCat));
        } else {
          emit(ActivationError(message: response.data));
        }
      } else {
        emit(ActivationInitial());
      }
    });
  }
}
