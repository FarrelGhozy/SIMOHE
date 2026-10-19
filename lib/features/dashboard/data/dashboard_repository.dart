import '../../../core/network/providers.dart';
import '../../../shared/models/device_info.dart';
import '../../../shared/models/enums.dart';
import '../../../shared/models/live_state.dart';
import '../../../shared/models/maturity_info.dart';
import '../../../shared/models/sensor_state.dart';

/// Live digabung dari 3 tabel (devices + latest_state + settings) agar bentuk
/// respons sama seperti `GET /api/live` lama.
class DashboardRepository extends DeviceScopedRepository {
  DashboardRepository(super.client);

  Future<LiveState> getLive() async {
    final id = await deviceId();
    final results = await Future.wait([
      guard(() => client.from('devices').select().eq('id', id).maybeSingle()),
      guard(
        () => client.from('latest_state').select().eq('device_id', id).maybeSingle(),
      ),
      guard(() => client.from('settings').select().eq('device_id', id).maybeSingle()),
    ]);
    final device = results[0];
    if (device == null) {
      throw const ApiException(
        code: 'DEVICE_NOT_FOUND',
        message: 'Belum ada device terdaftar.',
      );
    }
    final state = results[1] ?? const <String, dynamic>{};
    final settings = results[2] ?? const <String, dynamic>{};

    final ingestSec = toInt(settings['ingest_interval_sec'], 10);
    final lastSeen = toDateTimeOrNull(device['last_seen_at']);
    final online = toBool(device['is_online']) &&
        lastSeen != null &&
        DateTime.now().toUtc().difference(lastSeen.toUtc()).inSeconds <= ingestSec * 3;

    final holdMin = toInt(settings['mature_hold_min'], 30);
    final threshold = toDouble(settings['nh3_mature_ppm'], 25);
    final streak = toInt(state['mature_streak_sec']);

    return LiveState(
      device: DeviceInfo(
        id: '${device['id']}',
        name: (device['name'] ?? '') as String,
        location: device['location'] as String?,
        online: online,
        lastSeenAt: lastSeen,
        firmware: device['firmware_version'] as String?,
      ),
      state: SensorState(
        tempC: toDoubleOrNull(state['temp_c']),
        nh3Ppm: toDoubleOrNull(state['nh3_ppm']),
        tempOk: toBool(state['temp_ok'], true),
        heaterOn: toBool(state['heater_on']),
        valveOpen: toBool(state['valve_open']),
        mode: parseHeaterMode(state['mode'] as String?),
        status: parseDeviceStatus(state['status'] as String?),
        updatedAt: toDateTimeOrNull(state['updated_at']),
      ),
      maturity: MaturityInfo(
        mature: streak >= (holdMin * 60 < 1 ? 1 : holdMin * 60),
        progress: maturityProgress(streak, holdMin),
        thresholdPpm: threshold,
        holdMinutes: holdMin,
        streakSec: streak,
      ),
    );
  }
}
