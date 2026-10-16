import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/providers.dart';
import 'app_config.dart';

/// Preset interval yang boleh dipilih dari Pengaturan > Aplikasi.
class RefreshPresets {
  const RefreshPresets._();

  /// Detik.
  static const List<int> live = [5, 10, 15, 30];
  static const List<int> events = [15, 30, 60, 120];
  static const List<int> command = [3, 5, 10, 15];

  /// Detik (label ditampilkan dalam menit).
  static const List<int> trend = [30, 60, 120, 300, 900];
}

/// Preferensi interval ambil data aplikasi (lokal per perangkat).
///
/// Berbeda dari `settings` server (`history_interval_min`, `ingest_interval_sec`)
/// yang mengatur cron/firmware. Ini murni frekuensi polling saat app dibuka.
class AppRefreshSettings {
  const AppRefreshSettings({
    required this.liveSec,
    required this.eventsSec,
    required this.commandSec,
    required this.trendSec,
  });

  static const AppRefreshSettings defaults = AppRefreshSettings(
    liveSec: AppConfig.livePollIntervalSeconds,
    eventsSec: AppConfig.eventsPollIntervalSeconds,
    commandSec: AppConfig.commandPollIntervalSeconds,
    trendSec: 60,
  );

  final int liveSec;
  final int eventsSec;
  final int commandSec;
  final int trendSec;

  static const String _liveKey = 'prefs.refresh.live_sec';
  static const String _eventsKey = 'prefs.refresh.events_sec';
  static const String _commandKey = 'prefs.refresh.command_sec';
  static const String _trendKey = 'prefs.refresh.trend_sec';

  static int _clamp(int value, int min, int max) =>
      value < min ? min : (value > max ? max : value);

  factory AppRefreshSettings.load(SharedPreferences prefs) {
    return AppRefreshSettings(
      liveSec: _clamp(prefs.getInt(_liveKey) ?? defaults.liveSec, 5, 60),
      eventsSec: _clamp(prefs.getInt(_eventsKey) ?? defaults.eventsSec, 15, 120),
      commandSec:
          _clamp(prefs.getInt(_commandKey) ?? defaults.commandSec, 3, 15),
      trendSec: _clamp(prefs.getInt(_trendKey) ?? defaults.trendSec, 30, 900),
    );
  }

  Future<void> persist(SharedPreferences prefs) async {
    await prefs.setInt(_liveKey, liveSec);
    await prefs.setInt(_eventsKey, eventsSec);
    await prefs.setInt(_commandKey, commandSec);
    await prefs.setInt(_trendKey, trendSec);
  }

  AppRefreshSettings copyWith({
    int? liveSec,
    int? eventsSec,
    int? commandSec,
    int? trendSec,
  }) {
    return AppRefreshSettings(
      liveSec: liveSec ?? this.liveSec,
      eventsSec: eventsSec ?? this.eventsSec,
      commandSec: commandSec ?? this.commandSec,
      trendSec: trendSec ?? this.trendSec,
    );
  }

  Duration get live => Duration(seconds: liveSec);
  Duration get events => Duration(seconds: eventsSec);
  Duration get command => Duration(seconds: commandSec);
  Duration get trend => Duration(seconds: trendSec);
}

class RefreshSettingsNotifier extends Notifier<AppRefreshSettings> {
  @override
  AppRefreshSettings build() =>
      AppRefreshSettings.load(ref.watch(sharedPreferencesProvider));

  Future<void> save(AppRefreshSettings settings) async {
    await settings.persist(ref.read(sharedPreferencesProvider));
    state = settings;
  }
}

final refreshSettingsProvider =
    NotifierProvider<RefreshSettingsNotifier, AppRefreshSettings>(
  RefreshSettingsNotifier.new,
);
