import 'package:dio/dio.dart';

abstract class AIService {
  final Dio _dio;

  AIService(this._dio);

  Dio get dio => _dio;

  Future<String> sendRequest(String prompt, {int maxRetries = 3});
}