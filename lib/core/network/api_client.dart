import 'package:dio/dio.dart';

import '../config/app_config.dart';
import 'api_exception.dart';

/// Klien HTTP tipis di atas Dio yang menyisipkan Bearer token dan mengubah
/// error menjadi [ApiException] seragam.
class ApiClient {
  ApiClient({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: AppConfig.apiBaseUrl,
                connectTimeout: AppConfig.requestTimeout,
                receiveTimeout: AppConfig.requestTimeout,
                sendTimeout: AppConfig.requestTimeout,
                responseType: ResponseType.json,
              ),
            ) {
    _dio.options.headers['Authorization'] = 'Bearer ${AppConfig.appToken}';
    _dio.options.headers['Accept'] = 'application/json';
  }

  final Dio _dio;

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? query,
    required T Function(dynamic data) decode,
  }) async {
    try {
      final response = await _dio.get<dynamic>(path, queryParameters: query);
      return decode(response.data);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<T> post<T>(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    required T Function(dynamic data) decode,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        path,
        data: body,
        queryParameters: query,
      );
      return decode(response.data);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<T> put<T>(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    required T Function(dynamic data) decode,
  }) async {
    try {
      final response = await _dio.put<dynamic>(
        path,
        data: body,
        queryParameters: query,
      );
      return decode(response.data);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }
}
