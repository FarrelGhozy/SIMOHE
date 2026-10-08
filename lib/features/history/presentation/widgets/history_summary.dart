import 'package:flutter/material.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../shared/models/summary.dart';
import '../../../../shared/widgets/section_card.dart';

class HistorySummary extends StatelessWidget {
  const HistorySummary({super.key, required this.summary});

  final SummaryResponse summary;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Ringkasan',
      child: Wrap(
        spacing: 20,
        runSpacing: 16,
        children: [
          _Stat(label: 'Suhu min', value: Formatters.number(summary.tempC.min), unit: '°C'),
          _Stat(label: 'Suhu max', value: Formatters.number(summary.tempC.max), unit: '°C'),
          _Stat(label: 'Suhu rata-rata', value: Formatters.number(summary.tempC.avg), unit: '°C'),
          _Stat(label: 'NH3 min', value: Formatters.number(summary.nh3Ppm.min), unit: 'ppm'),
          _Stat(label: 'NH3 max', value: Formatters.number(summary.nh3Ppm.max), unit: 'ppm'),
          _Stat(label: 'NH3 rata-rata', value: Formatters.number(summary.nh3Ppm.avg), unit: 'ppm'),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, required this.unit});

  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 2),
        Text(
          '$value $unit',
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
