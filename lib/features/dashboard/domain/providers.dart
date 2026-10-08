import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/providers.dart';
import '../../../shared/models/enums.dart';
import '../../../shared/models/live_state.dart';
import '../../../shared/models/reading.dart';
import '../../history/domain/providers.dart';
import '../data/dashboard_repository.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>(
  (ref) => DashboardRepository(ref.watch(apiClientProvider)),
);

class LiveNotifier extends AsyncNotifier<LiveState> {
  Timer? _timer;

  @override
  Future<LiveState> build() async {
    _timer = Timer.periodic(
      const Duration(seconds: AppConfig.livePollIntervalSeconds),
      (_) => _poll(),
    );
    ref.onDispose(() => _timer?.cancel());
    return _fetch();
  }

  Future<LiveState> _fetch() async {
    final repository = ref.read(dashboardRepositoryProvider);
    try {
      final live = await repository.getLive();
      await ref.read(offlineCacheProvider).writeLive(live.toJson());
      return live;
    } on ApiException catch (error) {
      if (error.isNetwork) {
        final cached = ref.read(offlineCacheProvider).readLive();
        if (cached != null) return LiveState.fromJson(cached);
      }
      rethrow;
    }
  }

  Future<void> _poll() async {
    try {
      state = AsyncData(await _fetch());
    } on Object {
      // Pertahankan data terakhir saat polling gagal.
    }
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(_fetch);
  }
}

final liveProvider = AsyncNotifierProvider<LiveNotifier, LiveState>(
  LiveNotifier.new,
);

final dashboardTrendProvider = FutureProvider<List<ReadingPoint>>((ref) async {
  final repository = ref.watch(historyRepositoryProvider);
  final now = DateTime.now().toUtc();
  final response = await repository.getReadings(
    from: now.subtract(const Duration(hours: 24)),
    to: now,
    bucket: ReadingBucket.m15,
  );
  return response.items;
});
