import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/analysis_settings.dart';
import '../../../core/config/notification_prefs.dart';
import '../../../core/network/providers.dart';
import '../../../shared/models/enums.dart';
import '../../../shared/models/reading.dart';
import '../../dashboard/domain/providers.dart';
import '../../history/domain/providers.dart';
import '../../notifications/domain/providers.dart';
import '../data/stability_calc.dart';

/// Hasil satu putaran analisis stabilitas NH3.
class AnalysisData {
  const AnalysisData({
    required this.stability,
    required this.points,
    required this.analyzedAt,
    required this.windowMin,
    required this.thresholdPct,
    required this.fromRaw,
    required this.deviceOk,
    required this.gateReason,
    required this.mature,
    required this.notified,
  });

  final StabilityResult stability;

  /// Titik untuk grafik (sudah di-downsample bila perlu).
  final List<ReadingPoint> points;
  final DateTime analyzedAt;
  final int windowMin;
  final double thresholdPct;

  /// True bila sumbernya `telemetry_raw` (rapat); false bila fallback
  /// `sensor_readings` 15-menit.
  final bool fromRaw;

  /// False bila perangkat offline / sensor error / live belum siap.
  /// Bila false, % tetap ditampilkan tapi notifikasi diblokir.
  final bool deviceOk;
  final String? gateReason;

  /// matang = stabilitas ok + % ≥ ambang + perangkat sehat.
  final bool mature;

  /// True bila putaran ini memicu notifikasi sistem.
  final bool notified;
}

/// Analisis stabilitas NH3 full di HP dari data Supabase.
///
/// Alur tiap putaran: ambil `telemetry_raw` dalam window (fallback
/// `sensor_readings`), hitung % via [computeStability], cek gate
/// perangkat dari live (offline / `temp_ok` false / status error
/// memblokir notifikasi), lalu notifikasi lokal sekali (re-arm bila %
/// turun 5 poin di bawah ambang).
class AnalysisNotifier extends AsyncNotifier<AnalysisData> {
  static const String _armedKey = 'prefs.analysis.notify_armed';

  Timer? _timer;

  @override
  Future<AnalysisData> build() async {
    _restartTimer();
    ref.listen(analysisSettingsProvider, (_, _) {
      _restartTimer();
      _poll();
    });
    ref.onDispose(() => _timer?.cancel());
    return _analyze();
  }

  void _restartTimer() {
    _timer?.cancel();
    final sec = ref.read(analysisSettingsProvider).autoCheckSec;
    _timer = Timer.periodic(Duration(seconds: sec), (_) => _poll());
  }

  Future<void> _poll() async {
    try {
      state = AsyncData(await _analyze());
    } on Object {
      // Pertahankan hasil terakhir saat polling gagal.
    }
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(_analyze);
  }

  Future<AnalysisData> _analyze() async {
    final settings = ref.read(analysisSettingsProvider);
    final repository = ref.read(historyRepositoryProvider);
    final now = DateTime.now().toUtc();
    final from = now.subtract(Duration(minutes: settings.windowMin));

    var fromRaw = true;
    var response = await repository.getReadings(
      from: from,
      to: now,
      bucket: ReadingBucket.raw,
      limit: 1500,
    );
    var validCount =
        response.items.where((p) => p.nh3Ppm != null).length;
    if (validCount < settings.minSamples) {
      final fallback = await repository.getReadings(
        from: from,
        to: now,
        bucket: ReadingBucket.m15,
        limit: 1500,
      );
      final fallbackValid =
          fallback.items.where((p) => p.nh3Ppm != null).length;
      if (fallbackValid > validCount) {
        response = fallback;
        validCount = fallbackValid;
        fromRaw = false;
      }
    }

    final stability = computeStability(
      response.items.map((p) => p.nh3Ppm).toList(),
      rangeMaxPpm: settings.rangeMaxPpm,
      minSamples: settings.minSamples,
      minMeanPpm: settings.minMeanPpm,
    );

    final live = ref.read(liveProvider).asData?.value;
    var deviceOk = false;
    String? gateReason;
    if (live == null) {
      gateReason = 'Menunggu status perangkat…';
    } else if (!live.device.online) {
      gateReason = 'Perangkat offline — notifikasi matang dinonaktifkan.';
    } else if (!live.state.tempOk ||
        live.state.status == DeviceStatus.error) {
      gateReason = 'Sensor error (fail-safe) — notifikasi matang dinonaktifkan.';
    } else {
      deviceOk = true;
    }

    final mature = stability.status == StabilityStatus.ok &&
        (stability.percent ?? 0) >= settings.thresholdPct &&
        deviceOk;

    final notified = mature ? await _maybeNotify(stability, settings) : false;
    if (!mature &&
        stability.status == StabilityStatus.ok &&
        (stability.percent ?? 0) < settings.thresholdPct - 5) {
      await ref.read(sharedPreferencesProvider).setBool(_armedKey, true);
    }

    return AnalysisData(
      stability: stability,
      points: _downsample(response.items, 300),
      analyzedAt: now,
      windowMin: settings.windowMin,
      thresholdPct: settings.thresholdPct,
      fromRaw: fromRaw,
      deviceOk: deviceOk,
      gateReason: gateReason,
      mature: mature,
      notified: notified,
    );
  }

  /// Notifikasi sekali per periode stabil (re-arm saat % turun lagi).
  Future<bool> _maybeNotify(
    StabilityResult stability,
    AnalysisSettings settings,
  ) async {
    final prefs = ref.read(sharedPreferencesProvider);
    if (prefs.getBool(_armedKey) ?? true) {
      final notifPrefs = ref.read(notificationPrefsProvider);
      if (notifPrefs.enabled && notifPrefs.allows(EventSeverity.info)) {
        await ref.read(localNotificationServiceProvider).showMessage(
              title: 'Pupuk matang (stabil)',
              body:
                  'Stabilitas NH3 ${stability.percent!.toStringAsFixed(0)}% '
                  'selama ${settings.windowMin} menit. '
                  'Buka katup dari aplikasi bila sudah waktunya.',
            );
      }
      await prefs.setBool(_armedKey, false);
      return true;
    }
    return false;
  }

  static List<ReadingPoint> _downsample(List<ReadingPoint> items, int max) {
    if (items.length <= max) return items;
    final stride = (items.length / max).ceil();
    final out = <ReadingPoint>[];
    for (var i = 0; i < items.length; i += stride) {
      out.add(items[i]);
    }
    return out;
  }
}

final analysisProvider =
    AsyncNotifierProvider<AnalysisNotifier, AnalysisData>(
  AnalysisNotifier.new,
);
