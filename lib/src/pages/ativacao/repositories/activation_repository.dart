import 'dart:convert';
import 'dart:typed_data';

import 'package:Box4Pets/http/endpoint_dio.dart';
import 'package:Box4Pets/src/pages/ativacao/models/activation_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';

class ActivationRepository {
  final box = GetStorage();
  final http = EndpointDio();

  Future<Response<dynamic>> activateAccount(
      {required ActivationModel data}) async {
  
    try {
      final Response<dynamic> response =
          await http.dio.post('/app_ativacao', data: data.toMap());
  
      return response;
    } on DioException catch (e) {
   
      return e.response!;
    }
  }

  Future<Response<dynamic>> getRacas() async {
    try {
      final Response<dynamic> response =
          await http.dio.get('/raca_cao_ativacao');
         
      return response;
    } on DioException catch (e) {
      return e.response!;
    }
  }

  Future<Response<dynamic>> getRacasGato() async {
    try {
      final Response<dynamic> response =
          await http.dio.get('/raca_gato_ativacao');
      return response;
    } on DioException catch (e) {
      return e.response!;
    }
  }
}
