import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/device_detail.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../domain/providers.dart';
import 'widgets/batch_list.dart';
import 'widgets/device_info_card.dart';

class DeviceScreen extends ConsumerWidget {
  const DeviceScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    await Future.wait([
      ref.read(deviceProvider.notifier).refresh(),
      ref.read(batchesProvider.notifier).refresh(),
    ]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final device = ref.watch(deviceProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perangkat'),
        actions: [
          IconButton(
            tooltip: 'Muat ulang',
            icon: const Icon(Icons.refresh),
            onPressed: () => _refresh(ref),
          ),
        ],
      ),
      body: AsyncValueView<DeviceDetail>(
        value: device,
        onRetry: () => _refresh(ref),
        builder: (data) => RefreshIndicator(
          onRefresh: () => _refresh(ref),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              DeviceInfoCard(device: data),
              const SizedBox(height: 12),
              const BatchList(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
