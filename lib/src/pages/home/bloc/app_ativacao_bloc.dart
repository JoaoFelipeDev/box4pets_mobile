import 'dart:convert';

import 'package:Box4Pets/src/pages/home/models/app_blog_home_model.dart';
import 'package:Box4Pets/src/pages/home/models/download_pdf_model.dart';
import 'package:bloc/bloc.dart';
import 'package:Box4Pets/src/pages/home/models/app_ativacao_model.dart';
import 'package:Box4Pets/src/pages/home/repositories/app_ativacao_repository.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:meta/meta.dart';

import '../../ativacao/models/user_activation_model.dart';
import '../../destaques/models/blog_model.dart';

part 'app_ativacao_event.dart';
part 'app_ativacao_state.dart';

class AppAtivacaoBloc extends Bloc<AppAtivacaoEvent, AppAtivacaoState> {
  final box = GetStorage();
  final appAtivacaoRepository = AppAtivacaoRepository();
  AppAtivacaoBloc() : super(AppAtivacaoInitial()) {
    List<AppAtivacaoModel> list = [];
    List<BlogModel> blog = [];
    on<AppAtivacaoEvent>((event, emit) async {
      String json = box.read('user');
      UserActivationModel user = UserActivationModel.fromJson(jsonDecode(json));
      emit(AppAtivacaoLoading());
      final Response<dynamic> responseBlog =
          await appAtivacaoRepository.getBlog();
      if (responseBlog.statusCode != 200) {
      } else {
        print(responseBlog.data['records']);
        List<dynamic> responseMap = responseBlog.data['records'];
        blog = responseMap.map<BlogModel>((e) => BlogModel.fromMap(e)).toList();
      }
      if (event is AppAtivacaoGetEvent) {
        final Response<dynamic> response =
            await appAtivacaoRepository.getAppAtivacao();

        List<dynamic> result = response.data['records'];
        result.forEach((element) {
          print('${element['fields']['Nome do Pet']} - ${element['id']}');
        });
        list = result
            .map<AppAtivacaoModel>((e) => AppAtivacaoModel.fromMap(e))
            .toList();
        emit(AppAtivacaoLoaded(appAtivacao: list, user: user, blog: blog));

      } else if (event is AppAtivacaoGetFilterEvent) {
        List<AppAtivacaoModel> listFilter = [];

        listFilter = list
            .where((element) => element.status_aplicativo == event.filter)
            .toList();
        emit(
            AppAtivacaoLoaded(appAtivacao: listFilter, user: user, blog: blog));
      } else if (event is AppAtivacaoGetFilterNameEvent) {
        List<AppAtivacaoModel> listFilter = [];

        if (event.filter.isEmpty) {
          emit(AppAtivacaoLoaded(appAtivacao: list, user: user, blog: blog));
        } else {
          listFilter = list
              .where((element) => element.name
                  .toLowerCase()
                  .contains(event.filter.toLowerCase()))
              .toList();
        }
        emit(
            AppAtivacaoLoaded(appAtivacao: listFilter, user: user, blog: blog));
      }else if(event is AppAtivacaoSDownloadPDF){
        final Response<dynamic> response = await appAtivacaoRepository.downloadPDF(box: event.id);
        List<dynamic> result = response.data['records'];
        DownloadPDFModel downloadPDFModel = DownloadPDFModel.fromMap(result[0]);
        emit(AppDownloadPDF(downloadPDFModel: downloadPDFModel));
      }
    });
  }
}
