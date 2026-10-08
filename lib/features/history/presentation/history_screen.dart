import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/reading.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../domain/providers.dart';
import '../utils/csv_export.dart';
import 'widgets/history_chart.dart';
import 'widgets/history_summary.dart';
import 'widgets/range_selector.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  void _export(BuildContext context, List<ReadingPoint> points) {
    final messenger = ScaffoldMessenger.of(context);
    try {
      exportReadingsCsv(points);
      messenger.showSnackBar(
        const SnackBar(content: Text('File CSV diunduh.')),
      );
    } on UnsupportedError catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(error.message ?? 'Gagal')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyProvider);
    final notifier = ref.read(historyProvider.notifier);
    final selected = notifier.range;
    final points = history.asData?.value.readings.items ?? const <ReadingPoint>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat'),
        actions: [
          IconButton(
            tooltip: 'Ekspor CSV',
            icon: const Icon(Icons.download),
            onPressed:
                points.isEmpty ? null : () => _export(context, points),
          ),
        ],
      ),
      body: Column(
        children: [
          RangeSelector(
            selected: selected,
            onChanged: notifier.setRange,
          ),
          Expanded(
            child: AsyncValueView<HistoryData>(
              value: history,
              onRetry: notifier.refresh,
              builder: (data) => RefreshIndicator(
                onRefresh: notifier.refresh,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    HistorySummary(summary: data.summary),
                    const SizedBox(height: 12),
                    HistoryChart(
                      points: data.readings.items,
                      range: notifier.range,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
