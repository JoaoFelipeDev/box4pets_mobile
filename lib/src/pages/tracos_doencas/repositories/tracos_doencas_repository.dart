import 'package:Box4Pets/http/endpoint_dio.dart';
import 'package:dio/dio.dart';

class TracosDoencasRepository {
  final http = EndpointDio();
  Future<Response<dynamic>> getTracosDoencas({required String box}) async {
    try {
      final Response<dynamic> response = await http.dio
          .get('/app_resultado_resumo?filterByFormula=Ativacao="$box"');
      return response;
    } on DioException catch (e) {
      return e.response!;
    }
  }
}
