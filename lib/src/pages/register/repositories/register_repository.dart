import 'dart:convert';

import 'package:Box4Pets/http/endpoint_dio.dart';
import 'package:Box4Pets/src/pages/login/models/user_auth_model.dart';
import 'package:Box4Pets/src/pages/register/models/register_model.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';

class RegisterRepository {
  final box = GetStorage();
  final http = EndpointDio();
  Future<bool> register({required RegisterModel register}) async {
    try {
      final Response<dynamic> response =
          await http.dio.post('/app_usuarios', data: register.toMap());

      final UserAuthModel user =
          UserAuthModel.fromMap(response.data['records'][0]);
      box.write('user', json.encode(user.toJson()));
      return true;
    } on DioException {
      return false;
    }
  }

  Future<bool> findEmail({required RegisterModel register}) async {
    try {
      final Response<dynamic> response = await http.dio.get(
          '/app_usuarios?filterByFormula=Email="${register.email}"',
          data: register.toMap());
      List<dynamic> list = response.data['records'];
      int cont = list.length;

      if (cont == 0) {
        return true;
      } else {
        return false;
      }
    } on DioException {
      return false;
    }
  }
}
