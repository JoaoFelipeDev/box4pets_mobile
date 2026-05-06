import 'package:Box4Pets/http/endpoint_dio.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:convert';
import 'package:flutter/services.dart';



class AppListaDoencaRepository {
  final box = GetStorage();
  final http = EndpointDio();

  Future getListaDoenca(
      {required String id, required String especies}) async {
    String especie = '';

    if (especies == "Felina") {
      especie = "_gato";
    }
    try {
      final Response<dynamic> responseId =
          await http.dio.get('/app_lista_doenca$especie/$id');
      var result = responseId.data['fields']['Marcador'];
      // String filter = especies == 'Felina' ? '_gato' : '_cao';
      // ByteData conteudo =  await rootBundle.load('assets/json/data$filter.json');
      // List<dynamic> list = json.decode(Utf8Decoder().convert(conteudo.buffer.asUint8List()));
     

      // var res = list.firstWhere((element) => element['marcador'] == result);
     
      // var  jsonMap = json.decode(conteudo);
      // print(jsonMap);
      final Response<dynamic> response = await http.dio
          .get('/app_lista_doenca$especie?filterByFormula=Marcador="$result"');
      return response;
    } on DioException catch (e) {
      return e.response!;
    }
  }

  Future getListCategoria(String especies) async{
   
   
    String filter = especies == 'Felina' ? '_gato' : '_cao';
    ByteData conteudo =  await rootBundle.load('assets/json/data$filter.json');
      List<dynamic> list = json.decode(Utf8Decoder().convert(conteudo.buffer.asUint8List()));
      List categorias = list.map((e) => e['categoria']).toList();
      return categorias;
  }
}
