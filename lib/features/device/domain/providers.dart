import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/providers.dart';
import '../../../shared/models/batch.dart';
import '../../../shared/models/device_detail.dart';
import '../data/device_repository.dart';

final deviceRepositoryProvider = Provider<DeviceRepository>(
  (ref) => DeviceRepository(ref.watch(apiClientProvider)),
);

class DeviceNotifier extends AsyncNotifier<DeviceDetail> {
  @override
  Future<DeviceDetail> build() =>
      ref.read(deviceRepositoryProvider).getDevice();

  Future<void> refresh() async {
    state = await AsyncValue.guard(
      () => ref.read(deviceRepositoryProvider).getDevice(),
    );
  }
}

final deviceProvider = AsyncNotifierProvider<DeviceNotifier, DeviceDetail>(
  DeviceNotifier.new,
);

class BatchesNotifier extends AsyncNotifier<List<Batch>> {
  @override
  Future<List<Batch>> build() =>
      ref.read(deviceRepositoryProvider).getBatches();

  Future<void> refresh() async {
    state = await AsyncValue.guard(
      () => ref.read(deviceRepositoryProvider).getBatches(),
    );
  }
}

final batchesProvider = AsyncNotifierProvider<BatchesNotifier, List<Batch>>(
  BatchesNotifier.new,
);
