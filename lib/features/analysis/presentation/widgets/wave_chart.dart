import 'package:flutter/material.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../shared/models/reading.dart';
import '../../../../shared/widgets/section_card.dart';
import '../../../../shared/widgets/trend_chart.dart';

/// Grafik "gelombang + tabung": garis NH3 plus garis datar min & max
/// sebagai dinding tabung. Makin pipih jarak min–max = makin stabil.
class WaveChart extends StatelessWidget {
  const WaveChart({super.key, required this.points});

  final List<ReadingPoint> points;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (points.isEmpty) {
      return const SectionCard(
        title: 'Gelombang NH3',
        child: SizedBox(
          height: 220,
          child: Center(child: Text('Belum ada data pada window ini')),
        ),
      );
    }

    final values = points.map((p) => p.nh3Ppm).toList();
    final valids = values.whereType<double>().toList();
    final double? min =
        valids.isEmpty ? null : valids.reduce((a, b) => a < b ? a : b);
    final double? max =
        valids.isEmpty ? null : valids.reduce((a, b) => a > b ? a : b);

    return SectionCard(
      title: 'Gelombang NH3',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TrendChart(
            timestamps: points.map((p) => p.ts ?? DateTime.now()).toList(),
            height: 240,
            formatBottom: (value) =>
                Formatters.time(value).substring(0, 5),
            series: [
              if (max != null)
                TrendSeries(
                  label: 'Dinding atas',
                  color: theme.colorScheme.outlineVariant,
                  values: List.filled(values.length, max),
                ),
              TrendSeries(
                label: 'NH3',
                color: theme.colorScheme.primary,
                values: values,
              ),
              if (min != null)
                TrendSeries(
                  label: 'Dinding bawah',
                  color: theme.colorScheme.outlineVariant,
                  values: List.filled(values.length, min),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Garis atas–bawah = dinding tabung. Jaraknya = lebar tabung.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
