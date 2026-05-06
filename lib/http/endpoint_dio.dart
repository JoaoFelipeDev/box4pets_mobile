import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EndpointDio {
  EndpointDio() {
    final token = dotenv.env['AIRTABLE_TOKEN']?.trim() ?? '';
    final baseUrl = dotenv.env['AIRTABLE_BASE_URL']?.trim() ??
        'https://api.airtable.com/v0/appFtyAXSYJQ0UhNV';
    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      headers: {
        'Content-Type': 'application/json',
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    ));
  }

  late final Dio dio;
}
