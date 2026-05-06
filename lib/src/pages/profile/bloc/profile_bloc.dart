import 'dart:math';

import 'package:Box4Pets/src/pages/profile/models/change_password_model.dart';
import 'package:bloc/bloc.dart';
import 'package:Box4Pets/src/pages/profile/repositories/profile_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:meta/meta.dart';
import '../models/profile_model.dart';
import '../models/profile_editing_model.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final profileRespository = ProfileRepository();
  ProfileBloc() : super(ProfileInitial()) {
    on<ProfileEvent>((event, emit) async {
      emit(ProfileLoading());
      if (event is ProfileGetEvent) {
        final Response<dynamic> response = await profileRespository.getUser();

        if (response.statusCode == 200) {
          Map<String, dynamic> data = response.data;
          ProfileModel profileModel = ProfileModel.fromMap(data);
          emit(ProfileLoaded(proile: profileModel));
        }
      } else if (event is ProfileEditingEvent) {
        final Response<dynamic> response =
            await profileRespository.updateUser(profile: event.profile);
      
        if (response.statusCode == 200) {
          final Response<dynamic> responseCreate =
              await profileRespository.getUser();

          if (responseCreate.statusCode == 200) {
            Map<String, dynamic> data = responseCreate.data;
            ProfileModel profileModel = ProfileModel.fromMap(data);
            emit(ProfileLoaded(proile: profileModel));
          }
        }
      } else if (event is ProfileDeletAccountEvent) {
        final Response<dynamic> response =
            await profileRespository.deleteUser();

        if (response.statusCode == 200 || response.statusCode == 201) {
          emit(ProfileDelet());
        }
      }else if (event is ProfileChangePasswordEvent) {
        final Response<dynamic> response =
            await profileRespository.changePassword(password: event.password);

        if (response.statusCode == 200 || response.statusCode == 201) {
          emit(ProfileChangePasswordSuccess( message: 'Senha alterada com sucesso'));
        }
      }
    });
  }
}
