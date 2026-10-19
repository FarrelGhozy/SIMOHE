import '../../../core/network/providers.dart';
import '../../../shared/models/batch.dart';
import '../../../shared/models/device_detail.dart';

/// Info device + siklus: baca langsung PostgREST. Status online dihitung di
/// klien (is_online && last_seen dalam 3× ingest_interval).
class DeviceRepository extends DeviceScopedRepository {
  DeviceRepository(super.client);

  Future<DeviceDetail> getDevice() async {
    final id = await deviceId();
    final results = await Future.wait([
      guard(() => client.from('devices').select().eq('id', id).maybeSingle()),
      guard(() => client.from('settings').select('ingest_interval_sec').eq('device_id', id).maybeSingle()),
    ]);
    final device = results[0];
    if (device == null) {
      throw const ApiException(
        code: 'DEVICE_NOT_FOUND',
        message: 'Belum ada device terdaftar.',
      );
    }
    final settings = results[1] ?? const <String, dynamic>{};
    final ingestSec = toInt(settings['ingest_interval_sec'], 10);
    final lastSeen = toDateTimeOrNull(device['last_seen_at']);
    final online = toBool(device['is_online']) &&
        lastSeen != null &&
        DateTime.now().toUtc().difference(lastSeen.toUtc()).inSeconds <= ingestSec * 3;

    return DeviceDetail(
      id: '${device['id']}',
      name: (device['name'] ?? '') as String,
      location: device['location'] as String?,
      firmware: device['firmware_version'] as String?,
      isOnline: online,
      lastSeenAt: lastSeen,
      createdAt: toDateTimeOrNull(device['created_at']) ?? DateTime.now().toUtc(),
    );
  }

  Future<List<Batch>> getBatches({int limit = 50}) async {
    final id = await deviceId();
    final rows = await guard(
      () => client
          .from('batches')
          .select()
          .eq('device_id', id)
          .order('started_at', ascending: false)
          .limit(limit),
    ) as List;
    return rows
        .map((item) => Batch.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }
}
