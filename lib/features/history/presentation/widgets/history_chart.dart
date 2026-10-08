import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/models/reading.dart';
import '../../../../shared/widgets/section_card.dart';
import '../../../../shared/widgets/trend_chart.dart';
import '../../domain/providers.dart';

class HistoryChart extends StatelessWidget {
  const HistoryChart({
    super.key,
    required this.points,
    required this.range,
  });

  final List<ReadingPoint> points;
  final HistoryRange range;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = AppStatusColors.of(context);

    if (points.isEmpty) {
      return const SectionCard(
        title: 'Grafik',
        child: SizedBox(
          height: 220,
          child: Center(child: Text('Belum ada data pada rentang ini')),
        ),
      );
    }

    final timestamps = points.map((p) => p.ts ?? DateTime.now()).toList();
    final showTime = range == HistoryRange.last24h;

    return SectionCard(
      title: 'Grafik',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TrendChart(
            timestamps: timestamps,
            height: 260,
            formatBottom: (value) => showTime
                ? Formatters.time(value).substring(0, 5)
                : Formatters.date(value),
            series: [
              TrendSeries(
                label: 'Suhu',
                color: theme.colorScheme.primary,
                values: points.map((p) => p.tempC).toList(),
              ),
              TrendSeries(
                label: 'NH3',
                color: status.warning,
                values: points.map((p) => p.nh3Ppm).toList(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            children: [
              _Legend(color: theme.colorScheme.primary, label: 'Suhu (°C)'),
              _Legend(color: status.warning, label: 'NH3 (ppm)'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
