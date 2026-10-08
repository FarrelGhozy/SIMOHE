import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:simohe/core/network/api_exception.dart';

RequestOptions _options() => RequestOptions(path: '/api/live');

void main() {
  test('meneruskan error body dari server', () {
    final error = DioException(
      requestOptions: _options(),
      type: DioExceptionType.badResponse,
      response: Response<dynamic>(
        requestOptions: _options(),
        statusCode: 400,
        data: {
          'error': {'code': 'VALIDATION_ERROR', 'message': 'temp_c wajib angka'},
        },
      ),
    );

    final mapped = ApiException.fromDio(error);
    expect(mapped.code, 'VALIDATION_ERROR');
    expect(mapped.message, 'temp_c wajib angka');
    expect(mapped.statusCode, 400);
  });

  test('memetakan 401 tanpa body standar', () {
    final error = DioException(
      requestOptions: _options(),
      type: DioExceptionType.badResponse,
      response: Response<dynamic>(requestOptions: _options(), statusCode: 401),
    );

    final mapped = ApiException.fromDio(error);
    expect(mapped.isUnauthorized, isTrue);
    expect(mapped.code, 'UNAUTHORIZED');
  });

  test('memetakan timeout sebagai error jaringan', () {
    final error = DioException(
      requestOptions: _options(),
      type: DioExceptionType.connectionTimeout,
    );

    final mapped = ApiException.fromDio(error);
    expect(mapped.code, 'TIMEOUT');
    expect(mapped.isNetwork, isTrue);
  });

  test('memetakan connection error sebagai NETWORK', () {
    final error = DioException(
      requestOptions: _options(),
      type: DioExceptionType.connectionError,
    );

    expect(ApiException.fromDio(error).code, 'NETWORK');
  });

  test('memetakan 5xx sebagai SERVER_ERROR', () {
    final error = DioException(
      requestOptions: _options(),
      type: DioExceptionType.badResponse,
      response: Response<dynamic>(requestOptions: _options(), statusCode: 503),
    );

    expect(ApiException.fromDio(error).code, 'SERVER_ERROR');
  });
}
