import 'dart:convert';

import 'package:Box4Pets/src/pages/ativacao/models/user_activation_model.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../http/endpoint_dio.dart';

class AppAtivacaoRepository {
  final http = EndpointDio();
  final box = GetStorage();

  Future<Response<dynamic>> getAppAtivacao() async {
    String json = box.read('user');
    UserActivationModel user = UserActivationModel.fromJson(jsonDecode(json));
    String userEmail = user.email;
    try {
      final Response<dynamic> response = await http.dio
          .get('/app_ativacao?filterByFormula=Email_app_usuario="$userEmail"');
      return response;
      
    } on DioException catch (e) {
      return e.response!;
    }
  }

  Future<Response<dynamic>> getVersion() async {
    try {
      final Response<dynamic> response = await http.dio.get('/app_versoes');
      return response;
    } on DioException catch (e) {
      return e.response!;
    }
  }

  Future<Response<dynamic>> getBlog() async {
    try {
      final Response<dynamic> response = await http.dio.get('/blog_app');
      return response;
    } on DioException catch (e) {
      return e.response!;
    }
  }

  Future<Response<dynamic>> getAppResultadoRaca() async {
    String json = box.read('user');
    UserActivationModel user = UserActivationModel.fromJson(jsonDecode(json));
    String userEmail = user.email;

    try {
      final Response<dynamic> responseId = await http.dio
          .get('/app_ativacao?filterByFormula=Email_app_usuario="$userEmail"');
      var result = responseId.data['fields']['Case_ID'];
      final Response<dynamic> response = await http.dio
          .get('/app_resultado_raca?filterByFormula=Ativacao="$result"');
         
      return response;
      
    } on DioException catch (e) {
      return e.response!;
    }
  }

  Future<Response<dynamic>> getTracosDoencas({required String box}) async {
    try {
      final Response<dynamic> response = await http.dio
          .get('/app_resultado_resumo?filterByFormula=Ativacao="$box"');
          
      return response;
    } on DioException catch (e) {
      return e.response!;
    }
  }
  Future<Response<dynamic>> downloadPDF({required String box}) async {
    try {
      final Response<dynamic> response = await http.dio
          .get('/app_resultado_outrostestes?filterByFormula=Ativacao="$box"');
         
      return response;
      
    } on DioException catch (e) {
      return e.response!;
    }
  }

}
  
