import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:simohe/core/config/notification_prefs.dart';
import 'package:simohe/shared/models/enums.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('default mengizinkan semua severity', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();

    final settings = NotificationPrefs.load(prefs);

    expect(settings.enabled, isTrue);
    expect(settings.warnAndAboveOnly, isFalse);
    expect(settings.allows(EventSeverity.info), isTrue);
    expect(settings.allows(EventSeverity.critical), isTrue);
  });

  test('warnAndAboveOnly menyaring info', () {
    const settings = NotificationPrefs(
      enabled: true,
      warnAndAboveOnly: true,
    );

    expect(settings.allows(EventSeverity.info), isFalse);
    expect(settings.allows(EventSeverity.warning), isTrue);
    expect(settings.allows(EventSeverity.critical), isTrue);
  });

  test('simpan lalu baca kembali', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();

    const settings = NotificationPrefs(
      enabled: false,
      warnAndAboveOnly: true,
    );
    await settings.persist(prefs);

    final loaded = NotificationPrefs.load(prefs);
    expect(loaded.enabled, isFalse);
    expect(loaded.warnAndAboveOnly, isTrue);
  });
}
