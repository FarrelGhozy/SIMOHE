import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

/// Error seragam backend: `{ "error": { "code", "message" } }`
/// (Edge Functions) atau error PostgREST/jaringan.
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

  /// Petakan error Supabase (Postgrest/Functions/jaringan) ke [ApiException].
  factory ApiException.fromSupabase(Object error) {
    if (error is ApiException) return error;

    if (error is FunctionException) {
      final details = error.details;
      if (details is Map && details['error'] is Map) {
        final apiError = details['error'] as Map;
        final code = apiError['code'];
        final message = apiError['message'];
        if (code is String && message is String) {
          return ApiException(
            code: code,
            message: message,
            statusCode: error.status,
          );
        }
      }
      return ApiException(
        code: 'FUNCTION_ERROR',
        message: details is String && details.isNotEmpty
            ? details
            : 'Fungsi backend gagal.',
        statusCode: error.status,
      );
    }

    if (error is PostgrestException) {
      return ApiException(
        code: error.code ?? 'QUERY_ERROR',
        message: error.message,
      );
    }

    if (error is TimeoutException) {
      return const ApiException(
        code: 'TIMEOUT',
        message: 'Koneksi ke Supabase timeout.',
      );
    }

    if (error is SocketException ||
        error is HttpException ||
        error is HandshakeException) {
      return const ApiException(
        code: 'NETWORK',
        message: 'Tidak dapat terhubung ke Supabase.',
      );
    }

    final text = error.toString();
    if (text.contains('SocketException') ||
        text.contains('ClientException') ||
        text.contains('Connection closed') ||
        text.contains('Failed host lookup')) {
      return const ApiException(
        code: 'NETWORK',
        message: 'Tidak dapat terhubung ke Supabase.',
      );
    }

    return ApiException(
      code: 'UNKNOWN',
      message: 'Terjadi kesalahan tak terduga.',
    );
  }

  @override
  String toString() => 'ApiException($code): $message';
}
