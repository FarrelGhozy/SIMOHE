import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:simohe/core/config/refresh_settings.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('pakai default saat belum ada preferensi', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();

    final settings = AppRefreshSettings.load(prefs);

    expect(settings.liveSec, AppRefreshSettings.defaults.liveSec);
    expect(settings.eventsSec, AppRefreshSettings.defaults.eventsSec);
    expect(settings.commandSec, AppRefreshSettings.defaults.commandSec);
    expect(settings.trendSec, AppRefreshSettings.defaults.trendSec);
  });

  test('clamp nilai di luar batas wajar', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'prefs.refresh.live_sec': 1,
      'prefs.refresh.events_sec': 9999,
      'prefs.refresh.command_sec': 0,
      'prefs.refresh.trend_sec': 5,
    });
    final prefs = await SharedPreferences.getInstance();

    final settings = AppRefreshSettings.load(prefs);

    expect(settings.liveSec, 5);
    expect(settings.eventsSec, 120);
    expect(settings.commandSec, 3);
    expect(settings.trendSec, 30);
  });

  test('simpan lalu baca kembali', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();

    const settings = AppRefreshSettings(
      liveSec: 15,
      eventsSec: 60,
      commandSec: 10,
      trendSec: 300,
    );
    await settings.persist(prefs);

    expect(AppRefreshSettings.load(prefs).liveSec, 15);
    expect(AppRefreshSettings.load(prefs).eventsSec, 60);
    expect(AppRefreshSettings.load(prefs).commandSec, 10);
    expect(AppRefreshSettings.load(prefs).trendSec, 300);
  });
}
