import 'dart:convert';

import 'package:Box4Pets/http/endpoint_dio.dart';
import 'package:Box4Pets/src/pages/ativacao/models/user_activation_model.dart';
import 'package:Box4Pets/src/pages/parentesco/models/parentesco_model.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';

class ParentescoRepository {
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

  Future<Response<dynamic>> createParentesco({required ParentescoModel parentesco}) async {
    String json = box.read('user');
    UserActivationModel user = UserActivationModel.fromJson(jsonDecode(json));
    
    try {
      final Response<dynamic> response = await http.dio
          .post('/Paternidade' , data: parentesco.toMap());
      return response;
    } on DioException catch (e) {
      return e.response!;
    }
  }

}