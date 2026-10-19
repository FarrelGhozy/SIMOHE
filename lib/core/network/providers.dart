import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';
import 'api_exception.dart';
import 'offline_cache.dart';

export 'api_exception.dart';

/// Di-override saat bootstrap dengan instance [SharedPreferences].
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPreferencesProvider belum di-override'),
);

/// Klien Supabase (tanpa login, anon key). Butuh `Supabase.initialize`
/// di `main()` sebelum dipakai.
final supabaseClientProvider = Provider<SupabaseClient>(
  (ref) => Supabase.instance.client,
);

final offlineCacheProvider = Provider<OfflineCache>(
  (ref) => OfflineCache(ref.watch(sharedPreferencesProvider)),
);

/// Repository base: resolve device aktif (id terkecil, single-device)
/// sekali lalu di-cache per instance repository.
abstract class DeviceScopedRepository {
  DeviceScopedRepository(this.client);

  final SupabaseClient client;

  int? _deviceId;

  Future<int> deviceId() async {
    final cached = _deviceId;
    if (cached != null) return cached;
    final rows = await guard(
      () => client.from('devices').select('id').order('id').limit(1),
    );
    final list = rows as List;
    if (list.isEmpty) {
      throw const ApiException(
        code: 'DEVICE_NOT_FOUND',
        message: 'Belum ada device terdaftar.',
      );
    }
    final id = (list.first as Map)['id'];
    return _deviceId = (id as num).toInt();
  }
}

/// Bungkus query Supabase: timeout + mapping error seragam.
Future<T> guard<T>(Future<T> Function() run) async {
  try {
    return await run().timeout(AppConfig.requestTimeout);
  } on ApiException {
    rethrow;
  } catch (error) {
    throw ApiException.fromSupabase(error);
  }
}

/// Panggil Edge Function tulis (app-command/app-settings/app-batch).
Future<Map<String, dynamic>> invokeWrite(
  SupabaseClient client,
  String name,
  Map<String, dynamic> body,
) async {
  final response = await guard(
    () => client.functions.invoke(
      name,
      body: body,
      headers: AppConfig.functionHeaders,
    ),
  );
  final data = response.data;
  if (data is Map<String, dynamic>) return data;
  throw const ApiException(
    code: 'FUNCTION_ERROR',
    message: 'Respons fungsi tidak valid.',
  );
}

// ── Konversi baris PostgREST (snake_case) ke tipe Dart ────────────────────

int toInt(Object? value, [int fallback = 0]) =>
    value is num ? value.toInt() : fallback;

double? toDoubleOrNull(Object? value) =>
    value is num ? value.toDouble() : null;

double toDouble(Object? value, [double fallback = 0]) =>
    value is num ? value.toDouble() : fallback;

bool toBool(Object? value, [bool fallback = false]) =>
    value is bool ? value : fallback;

DateTime? toDateTimeOrNull(Object? value) =>
    value is String ? DateTime.tryParse(value) : null;

Map<String, dynamic> toStringMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return const {};
}

/// Kemajuan kematangan 0..1 (porting toMaturityInfo server).
double maturityProgress(int streakSec, int holdMin) {
  final holdSec = holdMin * 60 < 1 ? 1 : holdMin * 60;
  final progress = (streakSec / holdSec).clamp(0.0, 1.0);
  return double.parse(progress.toStringAsFixed(4));
}
