import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:simohe/core/network/api_exception.dart';
import 'package:simohe/core/network/offline_cache.dart';
import 'package:simohe/core/network/providers.dart';
import 'package:simohe/features/dashboard/data/dashboard_repository.dart';
import 'package:simohe/features/dashboard/domain/providers.dart';
import 'package:simohe/shared/models/device_info.dart';
import 'package:simohe/shared/models/enums.dart';
import 'package:simohe/shared/models/live_state.dart';
import 'package:simohe/shared/models/maturity_info.dart';
import 'package:simohe/shared/models/sensor_state.dart';

final _live = LiveState(
  device: const DeviceInfo(
    id: '1',
    name: 'Reaktor',
    online: false,
    firmware: '0.1.0',
  ),
  state: const SensorState(
    tempC: 30,
    nh3Ppm: 10,
    tempOk: true,
    heaterOn: false,
    valveOpen: false,
    mode: HeaterMode.auto,
    status: DeviceStatus.idle,
  ),
  maturity: const MaturityInfo(
    mature: false,
    progress: 0,
    thresholdPpm: 25,
    holdMinutes: 30,
    streakSec: 0,
  ),
);

class _FailingRepository implements DashboardRepository {
  _FailingRepository(this.error);

  final ApiException error;

  @override
  Future<LiveState> getLive() async => throw error;
}

void main() {
  test('kembalikan cache saat offline', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = await SharedPreferences.getInstance();
    await OfflineCache(preferences).writeLive(_live.toJson());

    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
        dashboardRepositoryProvider.overrideWithValue(
          _FailingRepository(
            const ApiException(code: 'NETWORK', message: 'offline'),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final result = await container.read(liveProvider.future);
    expect(result.device.name, 'Reaktor');
  });

  test('lempar ulang error non-jaringan', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = await SharedPreferences.getInstance();

    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
        dashboardRepositoryProvider.overrideWithValue(
          _FailingRepository(
            const ApiException(
              code: 'UNAUTHORIZED',
              message: 'token',
              statusCode: 401,
            ),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final subscription =
        container.listen<AsyncValue<LiveState>>(liveProvider, (_, _) {});
    addTearDown(subscription.close);
    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(subscription.read().hasError, isTrue);
    expect(subscription.read().error, isA<ApiException>());
  });
}
