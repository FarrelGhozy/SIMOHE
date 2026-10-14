import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:simohe/core/network/api_exception.dart';

void main() {
  test('meneruskan error body Edge Function { error: { code, message } }', () {
    final error = FunctionException(
      status: 400,
      details: {
        'error': {'code': 'VALIDATION_ERROR', 'message': 'temp_c wajib angka'},
      },
    );

    final mapped = ApiException.fromSupabase(error);
    expect(mapped.code, 'VALIDATION_ERROR');
    expect(mapped.message, 'temp_c wajib angka');
    expect(mapped.statusCode, 400);
  });

  test('memetakan 401 fungsi sebagai UNAUTHORIZED', () {
    final error = FunctionException(
      status: 401,
      details: {
        'error': {'code': 'UNAUTHORIZED', 'message': 'tidak valid'},
      },
    );

    final mapped = ApiException.fromSupabase(error);
    expect(mapped.isUnauthorized, isTrue);
    expect(mapped.code, 'UNAUTHORIZED');
  });

  test('memetakan timeout sebagai error jaringan', () {
    final mapped = ApiException.fromSupabase(
      TimeoutException('timeout', const Duration(seconds: 10)),
    );
    expect(mapped.code, 'TIMEOUT');
    expect(mapped.isNetwork, isTrue);
  });

  test('memetakan SocketException sebagai NETWORK', () {
    final mapped = ApiException.fromSupabase(
      const SocketException('Failed host lookup'),
    );
    expect(mapped.code, 'NETWORK');
    expect(mapped.isNetwork, isTrue);
  });

  test('memetakan PostgrestException dengan code/message', () {
    final mapped = ApiException.fromSupabase(
      const PostgrestException(message: 'row missing', code: 'PGRST116'),
    );
    expect(mapped.code, 'PGRST116');
    expect(mapped.message, 'row missing');
  });

  test('melewatkan ApiException apa adanya', () {
    const original = ApiException(code: 'NETWORK', message: 'x');
    expect(ApiException.fromSupabase(original), same(original));
  });
}
