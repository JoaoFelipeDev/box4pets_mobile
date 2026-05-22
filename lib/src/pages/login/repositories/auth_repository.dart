import 'package:Box4Pets/debug_agent_log.dart';
import 'package:Box4Pets/http/endpoint_dio.dart';
import 'package:Box4Pets/src/pages/login/models/auth_model.dart';
import 'package:Box4Pets/src/pages/login/models/auth_result.dart';
import 'package:Box4Pets/src/pages/login/models/user_auth_model.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:convert';

class AuthRepository {
  final box = GetStorage();
  final http = EndpointDio();

  Future<AuthResult> auth({required AuthModel auth}) async {
    try {
      agentDebugLog(
        location: 'auth_repository.dart:auth:start',
        message: 'auth request starting',
        hypothesisId: 'H-C',
        data: {
          'emailLength': auth.email.length,
          'emailHasAt': auth.email.contains('@'),
        },
      );
      final Response<dynamic> response = await http.dio.get(
        '/app_usuarios?filterByFormula=Email="${auth.email.trim()}"',
      );

      final list = response.data['records'] as List<dynamic>? ?? [];
      agentDebugLog(
        location: 'auth_repository.dart:auth:response',
        message: 'auth airtable response',
        hypothesisId: 'H-A',
        data: {
          'statusCode': response.statusCode,
          'recordCount': list.length,
          'hasPasswordField': list.isNotEmpty &&
              (list[0] as Map)['fields']?['Password'] != null,
        },
      );

      if (list.isEmpty) {
        agentDebugLog(
          location: 'auth_repository.dart:auth:empty',
          message: 'no user records found',
          hypothesisId: 'H-C',
          data: {'emailLength': auth.email.length},
        );
        return AuthResult.invalidCredentials();
      }

      final storedPassword =
          (list[0] as Map)['fields']?['Password']?.toString() ?? '';
      final inputPassword = auth.senha.trim();
      final passwordMatch = storedPassword == inputPassword;
      agentDebugLog(
        location: 'auth_repository.dart:auth:password',
        message: 'password comparison',
        hypothesisId: 'H-D',
        data: {
          'passwordMatch': passwordMatch,
          'storedPasswordLength': storedPassword.length,
          'inputPasswordLength': inputPassword.length,
        },
      );

      if (!passwordMatch) {
        return AuthResult.invalidCredentials();
      }

      final user = UserAuthModel.fromMap(list[0]);
      box.write('user', json.encode(user.toJson()));
      agentDebugLog(
        location: 'auth_repository.dart:auth:result',
        message: 'auth finished',
        hypothesisId: 'H-D',
        data: {'isAuth': true},
      );
      return AuthResult.authenticated();
    } on DioException catch (e) {
      agentDebugLog(
        location: 'auth_repository.dart:auth:dioError',
        message: 'dio exception during auth',
        hypothesisId: 'H-B',
        data: {
          'statusCode': e.response?.statusCode,
          'dioType': e.type.toString(),
          'message': e.message ?? '',
        },
      );
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        return AuthResult.apiUnauthorized();
      }
      return AuthResult.networkError();
    } catch (e) {
      agentDebugLog(
        location: 'auth_repository.dart:auth:error',
        message: 'unexpected auth error',
        hypothesisId: 'H-B',
        data: {'error': e.toString()},
      );
      return AuthResult.networkError();
    }
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
