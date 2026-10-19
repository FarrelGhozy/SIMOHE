import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../shared/models/enums.dart';
import '../network/providers.dart';

/// Preferensi notifikasi sistem (lokal per perangkat).
class NotificationPrefs {
  const NotificationPrefs({
    required this.enabled,
    required this.warnAndAboveOnly,
  });

  static const NotificationPrefs defaults = NotificationPrefs(
    enabled: true,
    warnAndAboveOnly: false,
  );

  final bool enabled;

  /// Bila true, hanya event `warning`/`critical` yang memicu notifikasi sistem.
  final bool warnAndAboveOnly;

  static const String _enabledKey = 'prefs.notif.enabled';
  static const String _warnKey = 'prefs.notif.warn_and_above';

  factory NotificationPrefs.load(SharedPreferences prefs) {
    return NotificationPrefs(
      enabled: prefs.getBool(_enabledKey) ?? defaults.enabled,
      warnAndAboveOnly: prefs.getBool(_warnKey) ?? defaults.warnAndAboveOnly,
    );
  }

  Future<void> persist(SharedPreferences prefs) async {
    await prefs.setBool(_enabledKey, enabled);
    await prefs.setBool(_warnKey, warnAndAboveOnly);
  }

  bool allows(EventSeverity severity) =>
      !warnAndAboveOnly || severity != EventSeverity.info;
}

class NotificationPrefsNotifier extends Notifier<NotificationPrefs> {
  @override
  NotificationPrefs build() =>
      NotificationPrefs.load(ref.watch(sharedPreferencesProvider));

  Future<void> save(NotificationPrefs prefs) async {
    await prefs.persist(ref.read(sharedPreferencesProvider));
    state = prefs;
  }
}

final notificationPrefsProvider =
    NotifierProvider<NotificationPrefsNotifier, NotificationPrefs>(
  NotificationPrefsNotifier.new,
);
