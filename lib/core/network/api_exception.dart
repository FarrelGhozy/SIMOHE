import 'package:dio/dio.dart';

/// Error seragam dari server: `{ "error": { "code", "message" } }`.
class ApiException implements Exception {
  const ApiException({
    required this.code,
    required this.message,
    this.statusCode,
  });

  final String code;
  final String message;
  final int? statusCode;

  bool get isUnauthorized => statusCode == 401 || code == 'UNAUTHORIZED';

  bool get isNetwork => code == 'NETWORK' || code == 'TIMEOUT';

  factory ApiException.fromDio(DioException error) {
    final status = error.response?.statusCode;
    final body = error.response?.data;

    if (body is Map && body['error'] is Map) {
      final apiError = body['error'] as Map;
      final code = apiError['code'];
      final message = apiError['message'];
      if (code is String && message is String) {
        return ApiException(code: code, message: message, statusCode: status);
      }
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return ApiException(
          code: 'TIMEOUT',
          message: 'Koneksi ke server timeout.',
          statusCode: status,
        );
      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        return ApiException(
          code: 'NETWORK',
          message: 'Tidak dapat terhubung ke server.',
          statusCode: status,
        );
      case DioExceptionType.badCertificate:
        return ApiException(
          code: 'NETWORK',
          message: 'Sertifikat server tidak valid.',
          statusCode: status,
        );
      case DioExceptionType.cancel:
        return ApiException(
          code: 'CANCELLED',
          message: 'Permintaan dibatalkan.',
          statusCode: status,
        );
      case DioExceptionType.badResponse:
        break;
    }

    if (status == 401) {
      return const ApiException(
        code: 'UNAUTHORIZED',
        message: 'Token aplikasi tidak valid.',
        statusCode: 401,
      );
    }
    if (status != null && status >= 500) {
      return ApiException(
        code: 'SERVER_ERROR',
        message: 'Server sedang bermasalah. Coba lagi.',
        statusCode: status,
      );
    }
    return ApiException(
      code: 'UNKNOWN',
      message: error.message ?? 'Terjadi kesalahan tak terduga.',
      statusCode: status,
    );
  }

  @override
  String toString() => 'ApiException($code): $message';
}
