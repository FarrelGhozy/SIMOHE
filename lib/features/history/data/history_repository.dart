import '../../../core/network/providers.dart';
import '../../../shared/models/enums.dart';
import '../../../shared/models/reading.dart';
import '../../../shared/models/summary.dart';

/// Histori: baca langsung PostgREST. `raw` dari telemetry_raw, `15m` dari
/// sensor_readings, `1h` diagregasi per jam di klien. Ringkasan dihitung dari
/// data yang sama (satu query).
class HistoryRepository extends DeviceScopedRepository {
  HistoryRepository(super.client);

  Future<ReadingsResponse> getReadings({
    required DateTime from,
    required DateTime to,
    required ReadingBucket bucket,
    int limit = 1000,
  }) async {
    final id = await deviceId();
    final isRaw = bucket == ReadingBucket.raw;
    final table = isRaw ? 'telemetry_raw' : 'sensor_readings';
    final timeCol = isRaw ? 'recorded_at' : 'sampled_at';

    final rows = await guard(
      () => client
          .from(table)
          .select()
          .eq('device_id', id)
          .gte(timeCol, from.toUtc().toIso8601String())
          .lte(timeCol, to.toUtc().toIso8601String())
          .order(timeCol, ascending: true)
          .limit(limit),
    );

    var items = rows.map((item) {
      final row = item;
      return ReadingPoint(
        ts: toDateTimeOrNull(row[timeCol]),
        tempC: toDoubleOrNull(row['temp_c']),
        nh3Ppm: toDoubleOrNull(row['nh3_ppm']),
        heaterOn: toBool(row['heater_on']),
        valveOpen: toBool(row['valve_open']),
      );
    }).toList();

    if (bucket == ReadingBucket.h1) items = _aggregateHourly(items);

    return ReadingsResponse(
      bucket: bucket,
      from: from,
      to: to,
      items: items,
    );
  }

  Future<SummaryResponse> getSummary(String range) async {
    final now = DateTime.now().toUtc();
    final window = switch (range) {
      '7d' => const Duration(days: 7),
      '30d' => const Duration(days: 30),
      _ => const Duration(hours: 24),
    };
    final response = await getReadings(
      from: now.subtract(window),
      to: now,
      bucket: ReadingBucket.m15,
      limit: 5000,
    );
    final temps = response.items.map((e) => e.tempC).whereType<double>().toList();
    final gases = response.items.map((e) => e.nh3Ppm).whereType<double>().toList();

    MetricStats stats(List<double> values) => values.isEmpty
        ? const MetricStats()
        : MetricStats(
            min: values.reduce((a, b) => a < b ? a : b),
            max: values.reduce((a, b) => a > b ? a : b),
            avg: values.reduce((a, b) => a + b) / values.length,
          );

    return SummaryResponse(
      from: response.from ?? now.subtract(window),
      to: response.to ?? now,
      rangeCount: response.items.length,
      tempC: stats(temps),
      nh3Ppm: stats(gases),
    );
  }

  /// Agregasi per jam UTC: rata-rata suhu/NH3, OR untuk aktuator.
  List<ReadingPoint> _aggregateHourly(List<ReadingPoint> items) {
    final buckets = <int, List<ReadingPoint>>{};
    for (final item in items) {
      final ts = item.ts;
      if (ts == null) continue;
      final hour = DateTime.utc(ts.year, ts.month, ts.day, ts.hour)
          .millisecondsSinceEpoch;
      (buckets[hour] ??= []).add(item);
    }
    final result = <ReadingPoint>[];
    final keys = buckets.keys.toList()..sort();
    for (final key in keys) {
      final group = buckets[key]!;
      final temps = group.map((e) => e.tempC).whereType<double>().toList();
      final gases = group.map((e) => e.nh3Ppm).whereType<double>().toList();
      result.add(
        ReadingPoint(
          ts: DateTime.fromMillisecondsSinceEpoch(key, isUtc: true),
          tempC: temps.isEmpty ? null : temps.reduce((a, b) => a + b) / temps.length,
          nh3Ppm: gases.isEmpty ? null : gases.reduce((a, b) => a + b) / gases.length,
          heaterOn: group.any((e) => e.heaterOn),
          valveOpen: group.any((e) => e.valveOpen),
        ),
      );
    }
    return result;
  }
}
