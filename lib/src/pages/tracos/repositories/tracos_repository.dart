import 'package:Box4Pets/http/endpoint_dio.dart';
import 'package:dio/dio.dart';

class TracosRepository {
  final http = EndpointDio();

  Future<Response<dynamic>> getTracos(String id, String especie) async {
    String _especie = "";

    if (especie == "Felina") {
      _especie = "_gato";
    }
    try {
      final Response<dynamic> response = await http.dio
          .get('/app_lista_tracos$_especie?filterByFormula=Categoria="$id"');
      return response;
    } on DioException catch (e) {
      return e.response!;
    }
  }
}
