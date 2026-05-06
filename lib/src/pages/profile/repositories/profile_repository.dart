import 'dart:convert';
import 'dart:io';

import 'package:Box4Pets/http/endpoint_dio.dart';
import 'package:Box4Pets/src/pages/ativacao/models/user_activation_model.dart';
import 'package:Box4Pets/src/pages/profile/models/change_password_model.dart';
import 'package:Box4Pets/src/pages/profile/models/profile_editing_model.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';

class ProfileRepository {
  final http = EndpointDio();
  final box = GetStorage();

  Future<Response<dynamic>> getUser() async {
    String json = box.read('user');
    UserActivationModel user = UserActivationModel.fromJson(jsonDecode(json));
    String userId = user.id;

    try {
      final Response<dynamic> response =
          await http.dio.get('/app_usuarios/$userId');
      return response;
    } on DioException catch (e) {
      return e.response!;
    }
  }

  Future<Response<dynamic>> updateUser(
      {required ProfileEditingModel profile}) async {
    String json = box.read('user');

    try {
      final Response<dynamic> response =
          await http.dio.patch('/app_usuarios', data: profile.toMap());
      return response;
    } on DioException catch (e) {
      return e.response!;
    }
  }

  Future<Response<dynamic>> deleteUser() async {
    String json = box.read('user');
    UserActivationModel user = UserActivationModel.fromJson(jsonDecode(json));

    try {
      final Response<dynamic> response = await http.dio
          .patch('/app_usuarios_app', data: {"Conta ativa": false});
      return response;
    } on DioException catch (e) {
      return e.response!;
    }
  }

  Future<Response<dynamic>> changePassword({required ChangePasswordmodel password}) async {
    String json = box.read('user');
    UserActivationModel user = UserActivationModel.fromJson(jsonDecode(json));

    try {
      final Response<dynamic> response = await http.dio.patch(
          '/app_usuarios',
          data: password.toMap(),
         );
      return response;
    } on DioException catch (e) {
      return e.response!;
    }
  }
}
