import 'package:Box4Pets/http/endpoint_dio.dart';
import 'package:dio/dio.dart';

class BlogRepository {
  final http = EndpointDio();

  Future<Response<dynamic>> getBlog() async {
    try {
      final Response<dynamic> response = await http.dio.get('/blog_app');
      return response;
    } on DioException catch (e) {
      return e.response!;
    }
  }
}
