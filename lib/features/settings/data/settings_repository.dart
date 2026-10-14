import '../../../core/network/providers.dart';
import '../../../shared/models/settings.dart';

/// Pengaturan: baca langsung PostgREST, tulis via Edge Function
/// `app-settings` (validasi batas wajar di sisi server).
class SettingsRepository extends DeviceScopedRepository {
  SettingsRepository(super.client);

  Future<AppSettings> getSettings() async {
    final id = await deviceId();
    final row = await guard(
      () => client.from('settings').select().eq('device_id', id).maybeSingle(),
    );
    if (row == null) {
      throw const ApiException(
        code: 'SETTINGS_MISSING',
        message: 'Pengaturan belum tersedia.',
      );
    }
    return AppSettings.fromJson(_normalize(row));
  }

  Future<AppSettings> updateSettings(SettingsPatch patch) async {
    final data = await invokeWrite(client, 'app-settings', patch.toJson());
    return AppSettings.fromJson(_normalize(data));
  }

  /// Normalisasi tipe baris agar cocok dengan model freezed.
  Map<String, dynamic> _normalize(Map<String, dynamic> row) => {
        ...row,
        'history_interval_min': toInt(row['history_interval_min'], 15),
        'ingest_interval_sec': toInt(row['ingest_interval_sec'], 10),
        'temp_min_c': toDouble(row['temp_min_c'], 30),
        'temp_max_c': toDouble(row['temp_max_c'], 45),
        'temp_hysteresis_c': toDouble(row['temp_hysteresis_c'], 2),
        'nh3_mature_ppm': toDouble(row['nh3_mature_ppm'], 25),
        'mature_hold_min': toInt(row['mature_hold_min'], 30),
        'heater_auto': toBool(row['heater_auto'], true),
        'heater_max_on_min': toInt(row['heater_max_on_min'], 60),
        'valve_max_open_min': toInt(row['valve_max_open_min'], 10),
        'command_ttl_sec': toInt(row['command_ttl_sec'], 60),
        'raw_retention_days': toInt(row['raw_retention_days'], 30),
      };
}
