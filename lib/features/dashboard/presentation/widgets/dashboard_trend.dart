import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/section_card.dart';
import '../../../../shared/widgets/trend_chart.dart';
import '../../domain/providers.dart';

class DashboardTrend extends ConsumerWidget {
  const DashboardTrend({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final status = AppStatusColors.of(context);
    final trend = ref.watch(dashboardTrendProvider);

    return SectionCard(
      title: 'Tren 24 jam',
      child: trend.when(
        loading: () => const SizedBox(
          height: 200,
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (error, _) => SizedBox(
          height: 200,
          child: Center(child: Text('Gagal memuat tren: $error')),
        ),
        data: (points) {
          if (points.isEmpty) {
            return const SizedBox(
              height: 200,
              child: Center(child: Text('Belum ada data')),
            );
          }
          final timestamps =
              points.map((p) => p.ts ?? DateTime.now()).toList();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TrendChart(
                timestamps: timestamps,
                height: 200,
                formatBottom: (value) =>
                    Formatters.time(value).substring(0, 5),
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
              const SizedBox(height: 8),
              Wrap(
                spacing: 16,
                children: [
                  _LegendDot(color: theme.colorScheme.primary, label: 'Suhu'),
                  _LegendDot(color: status.warning, label: 'NH3'),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

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
