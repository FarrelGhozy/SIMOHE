import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Cache nilai live terakhir agar UI tetap menampilkan data saat offline.
class OfflineCache {
  OfflineCache(this._prefs);

  final SharedPreferences _prefs;

  static const String _liveKey = 'cache.live_state';

  Map<String, dynamic>? readLive() {
    final raw = _prefs.getString(_liveKey);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic> ? decoded : null;
    } on FormatException {
      return null;
    }
  }

  Future<void> writeLive(Map<String, dynamic> json) =>
      _prefs.setString(_liveKey, jsonEncode(json));
}
