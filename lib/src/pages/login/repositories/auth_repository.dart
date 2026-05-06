import 'package:Box4Pets/http/endpoint_dio.dart';
import 'package:Box4Pets/src/pages/login/models/auth_model.dart';
import 'package:Box4Pets/src/pages/login/models/user_auth_model.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:convert';

class AuthRepository {
  final box = GetStorage();
  final http = EndpointDio();

  Future<bool> auth({required AuthModel auth}) async {
 
    bool isAuth = false;
    final Response<dynamic> response = await http.dio.get('/app_usuarios?filterByFormula=Email="${auth.email}"');

    

    List<dynamic> list = response.data['records'];
 
    late final UserAuthModel user;

    if(list.isNotEmpty){
      if(list[0]['fields']['Password'] == auth.senha){
isAuth = true;
          user = UserAuthModel.fromMap(list[0]);

          box.write('user', json.encode(user.toJson()));
    }
    }else{
      isAuth = false;
    }

 
    return isAuth;
  }

  Future<Response<dynamic>> getUser(String email) async {
    
    final Response<dynamic> response = await http.dio.get('/app_usuarios?filterByFormula=Email="$email"');
    return response;
  }
  Future <Response<dynamic>> setCode(String id, String code) async{
    try {
      final Response<dynamic> response = await http.dio.patch(
          '/app_usuarios',
          data: {"records": [
        {
          "id": id,
          "fields": {
            'token_change_password': code,
          }
        }
      ]},
         );
      return response;
    } on DioException catch (e) {
      return e.response!;
    }
  }

  Future <Response<dynamic>> checkCode(String code) async{
    try {
      final Response<dynamic> response = await http.dio.get(
          '/app_usuarios?filterByFormula=token_change_password="$code"',
         );
      return response;
    } on DioException catch (e) {
      return e.response!;
    }
  }

  Future <Response<dynamic>> changePassword(String id, String password) async{
    print('id: $id');
    try {
      final Response<dynamic> response = await http.dio.patch(
          '/app_usuarios',
          data: {
            "records": [
             
              {
                 "id": id,
                "fields": {
                  'Password': password,
                  'token_change_password': ''
                },
               
              }
            ]
          },
         );
      return response;
    } on DioException catch (e) {
      return e.response!;
    }
  }
}
