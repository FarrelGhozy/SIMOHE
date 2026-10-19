import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/providers.dart';

/// Pengaturan analisis stabilitas NH3 (lokal per perangkat).
///
/// Ini adalah "pengaturan interval pengambilan data selama beberapa menit"
/// versi client-only: window waktu yang diambil dari Supabase saat tombol
/// Analisis ditekan, plus ambang % matang dan toleransi tabung.
class AnalysisSettings {
  const AnalysisSettings({
    required this.windowMin,
    required this.rangeMaxPpm,
    required this.thresholdPct,
    required this.minSamples,
    required this.minMeanPpm,
    required this.autoCheckSec,
  });

  static const AnalysisSettings defaults = AnalysisSettings(
    windowMin: 60,
    rangeMaxPpm: 15,
    thresholdPct: 85,
    minSamples: 8,
    minMeanPpm: 1,
    autoCheckSec: 120,
  );

  /// Lebar window data yang diambil (menit).
  final int windowMin;

  /// Lebar tabung (range ppm) yang dianggap 0% stabil.
  final double rangeMaxPpm;

  /// % stabilitas minimal agar dianggap matang + notifikasi.
  final double thresholdPct;

  /// Minimal titik valid agar boleh dinilai.
  final int minSamples;

  /// Lantai sensor; rata-rata di bawah ini = sensor mati.
  final double minMeanPpm;

  /// Interval cek otomatis saat halaman Analisis dibuka (detik).
  final int autoCheckSec;

  static const List<int> windowPresets = [15, 30, 60, 120];
  static const List<int> autoCheckPresets = [60, 120, 300];

  static const String _windowKey = 'prefs.analysis.window_min';
  static const String _rangeMaxKey = 'prefs.analysis.range_max_ppm';
  static const String _thresholdKey = 'prefs.analysis.threshold_pct';
  static const String _minSamplesKey = 'prefs.analysis.min_samples';
  static const String _minMeanKey = 'prefs.analysis.min_mean_ppm';
  static const String _autoCheckKey = 'prefs.analysis.auto_check_sec';

  static int _clampInt(int value, int min, int max) =>
      value < min ? min : (value > max ? max : value);

  static double _clampDouble(double value, double min, double max) =>
      value < min ? min : (value > max ? max : value);

  factory AnalysisSettings.load(SharedPreferences prefs) {
    return AnalysisSettings(
      windowMin: _clampInt(
        prefs.getInt(_windowKey) ?? defaults.windowMin,
        5,
        240,
      ),
      rangeMaxPpm: _clampDouble(
        prefs.getDouble(_rangeMaxKey) ?? defaults.rangeMaxPpm,
        2,
        50,
      ),
      thresholdPct: _clampDouble(
        prefs.getDouble(_thresholdKey) ?? defaults.thresholdPct,
        50,
        98,
      ),
      minSamples: _clampInt(
        prefs.getInt(_minSamplesKey) ?? defaults.minSamples,
        4,
        30,
      ),
      minMeanPpm: _clampDouble(
        prefs.getDouble(_minMeanKey) ?? defaults.minMeanPpm,
        0.1,
        10,
      ),
      autoCheckSec: _clampInt(
        prefs.getInt(_autoCheckKey) ?? defaults.autoCheckSec,
        30,
        900,
      ),
    );
  }

  Future<void> persist(SharedPreferences prefs) async {
    await prefs.setInt(_windowKey, windowMin);
    await prefs.setDouble(_rangeMaxKey, rangeMaxPpm);
    await prefs.setDouble(_thresholdKey, thresholdPct);
    await prefs.setInt(_minSamplesKey, minSamples);
    await prefs.setDouble(_minMeanKey, minMeanPpm);
    await prefs.setInt(_autoCheckKey, autoCheckSec);
  }

  AnalysisSettings copyWith({
    int? windowMin,
    double? rangeMaxPpm,
    double? thresholdPct,
    int? minSamples,
    double? minMeanPpm,
    int? autoCheckSec,
  }) {
    return AnalysisSettings(
      windowMin: windowMin ?? this.windowMin,
      rangeMaxPpm: rangeMaxPpm ?? this.rangeMaxPpm,
      thresholdPct: thresholdPct ?? this.thresholdPct,
      minSamples: minSamples ?? this.minSamples,
      minMeanPpm: minMeanPpm ?? this.minMeanPpm,
      autoCheckSec: autoCheckSec ?? this.autoCheckSec,
    );
  }
}

class AnalysisSettingsNotifier extends Notifier<AnalysisSettings> {
  @override
  AnalysisSettings build() =>
      AnalysisSettings.load(ref.watch(sharedPreferencesProvider));

  Future<void> save(AnalysisSettings settings) async {
    await settings.persist(ref.read(sharedPreferencesProvider));
    state = settings;
  }
}

final analysisSettingsProvider =
    NotifierProvider<AnalysisSettingsNotifier, AnalysisSettings>(
  AnalysisSettingsNotifier.new,
);
