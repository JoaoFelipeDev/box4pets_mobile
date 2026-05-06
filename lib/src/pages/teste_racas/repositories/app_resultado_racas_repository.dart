import 'package:Box4Pets/http/endpoint_dio.dart';
import 'package:dio/dio.dart';

class AppResultadoRacasRepository {
  final http = EndpointDio();

  Future<Response<dynamic>> getResultadoRacas({required String id}) async {
    try {
      final Response<dynamic> response = await http.dio
          .get('/app_resultado_raca?filterByFormula=Ativacao="$id"');
      return response;
    } on DioException catch (e) {
      return e.response!;
    }
  }

  Future<Response<dynamic>> getRacas({required String id}) async {
    try {
      final Response<dynamic> response =
          await http.dio.get('/lista_de_racas/$id');
      return response;
    } on DioException catch (e) {
      return e.response!;
    }
  }
}
