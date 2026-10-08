import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:simohe/app.dart';
import 'package:simohe/core/network/providers.dart';
import 'package:simohe/features/dashboard/domain/providers.dart';
import 'package:simohe/features/notifications/domain/providers.dart';
import 'package:simohe/features/settings/domain/providers.dart';
import 'package:simohe/shared/models/device_info.dart';
import 'package:simohe/shared/models/enums.dart';
import 'package:simohe/shared/models/event_item.dart';
import 'package:simohe/shared/models/live_state.dart';
import 'package:simohe/shared/models/maturity_info.dart';
import 'package:simohe/shared/models/reading.dart';
import 'package:simohe/shared/models/sensor_state.dart';
import 'package:simohe/shared/models/settings.dart';

final _sampleLive = LiveState(
  device: DeviceInfo(
    id: '1',
    name: 'Reaktor Pupuk 1',
    online: true,
    firmware: '0.1.0',
    lastSeenAt: DateTime.utc(2026, 10, 8, 10),
  ),
  state: SensorState(
    tempC: 33.2,
    nh3Ppm: 12.5,
    tempOk: true,
    heaterOn: false,
    valveOpen: false,
    mode: HeaterMode.auto,
    status: DeviceStatus.idle,
    updatedAt: DateTime.utc(2026, 10, 8, 10),
  ),
  maturity: const MaturityInfo(
    mature: false,
    progress: 0.25,
    thresholdPpm: 25,
    holdMinutes: 30,
    streakSec: 450,
  ),
);

final _sampleSettings = AppSettings(
  id: 1,
  deviceId: 1,
  historyIntervalMin: 15,
  ingestIntervalSec: 10,
  tempMinC: 30,
  tempMaxC: 45,
  tempHysteresisC: 2,
  nh3MaturePpm: 25,
  matureHoldMin: 30,
  heaterAuto: true,
  heaterMaxOnMin: 60,
  valveMaxOpenMin: 10,
  commandTtlSec: 60,
  rawRetentionDays: 30,
  updatedAt: DateTime.utc(2026, 10, 8),
);

class _StubLiveNotifier extends LiveNotifier {
  @override
  Future<LiveState> build() async => _sampleLive;
}

class _StubEventsNotifier extends EventsNotifier {
  @override
  Future<EventsResponse> build() async => const EventsResponse();
}

class _StubSettingsNotifier extends SettingsNotifier {
  @override
  Future<AppSettings> build() async => _sampleSettings;
}

void main() {
  testWidgets('Shell menampilkan navigasi utama', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = await SharedPreferences.getInstance();

    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
          liveProvider.overrideWith(_StubLiveNotifier.new),
          eventsProvider.overrideWith(_StubEventsNotifier.new),
          settingsProvider.overrideWith(_StubSettingsNotifier.new),
          dashboardTrendProvider.overrideWith(
            (ref) async => <ReadingPoint>[],
          ),
        ],
        child: const SimoheApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Dashboard'), findsWidgets);
    expect(find.text('Riwayat'), findsOneWidget);
  });
}
