import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/brand_colors.dart';
import '../../../shared/models/live_state.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../../../shared/widgets/brand_icon.dart';
import '../domain/providers.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/dashboard_trend.dart';
import 'widgets/maturity_progress.dart';
import 'widgets/quick_controls.dart';
import 'widgets/sensor_metrics.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  Future<void> _refreshAll(WidgetRef ref) async {
    await Future.wait([
      ref.read(liveProvider.notifier).refresh(),
      ref.read(dashboardTrendProvider.notifier).refresh(),
    ]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final live = ref.watch(liveProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            BrandIcon(asset: BrandAssets.emblem, size: 28),
            SizedBox(width: 10),
            Text('SIMOHE'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Muat ulang',
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshAll(ref),
          ),
        ],
      ),
      body: AsyncValueView<LiveState>(
        value: live,
        onRetry: () => _refreshAll(ref),
        builder: (data) => RefreshIndicator(
          onRefresh: () => _refreshAll(ref),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              DashboardHeader(live: data),
              const SizedBox(height: 12),
              SensorMetrics(live: data),
              const SizedBox(height: 12),
              MaturityProgress(live: data),
              const SizedBox(height: 12),
              QuickControls(live: data),
              const SizedBox(height: 12),
              const DashboardTrend(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
