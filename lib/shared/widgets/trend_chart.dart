import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class TrendSeries {
  const TrendSeries({
    required this.label,
    required this.color,
    required this.values,
  });

  final String label;
  final Color color;
  final List<double?> values;
}

/// Grafik garis generik untuk satu atau dua seri.
class TrendChart extends StatelessWidget {
  const TrendChart({
    super.key,
    required this.timestamps,
    required this.series,
    this.height = 220,
    this.formatBottom,
    this.formatLeft,
    this.minY,
    this.maxY,
  });

  final List<DateTime> timestamps;
  final List<TrendSeries> series;
  final double height;
  final String Function(DateTime value)? formatBottom;
  final String Function(double value)? formatLeft;
  final double? minY;
  final double? maxY;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (timestamps.isEmpty || series.every((s) => s.values.every((v) => v == null))) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            'Belum ada data',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ),
      );
    }

    final maxIndex = timestamps.length - 1;
    final step = (timestamps.length / 4).ceil().clamp(1, timestamps.length);
    final labelEvery = step == 0 ? 1 : step;

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          minY: minY,
          maxY: maxY,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: theme.dividerColor.withValues(alpha: 0.4),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 48,
                getTitlesWidget: (value, meta) {
                  if (value == meta.min || value == meta.max) {
                    return const SizedBox.shrink();
                  }
                  final text = formatLeft?.call(value) ??
                      value.toStringAsFixed(value.abs() >= 100 ? 0 : 1);
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Text(text, style: theme.textTheme.labelSmall),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final index = value.round();
                  if (index < 0 || index > maxIndex) {
                    return const SizedBox.shrink();
                  }
                  if (index != 0 && index != maxIndex && index % labelEvery != 0) {
                    return const SizedBox.shrink();
                  }
                  final text = formatBottom?.call(timestamps[index]) ?? '';
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(text, style: theme.textTheme.labelSmall),
                  );
                },
              ),
            ),
          ),
          lineTouchData: const LineTouchData(enabled: true),
          lineBarsData: [
            for (final item in series)
              LineChartBarData(
                spots: [
                  for (var i = 0; i < item.values.length; i++)
                    if (item.values[i] != null)
                      FlSpot(i.toDouble(), item.values[i]!),
                ],
                isCurved: true,
                curveSmoothness: 0.2,
                preventCurveOverShooting: true,
                color: item.color,
                barWidth: 2,
                dotData: const FlDotData(show: false),
              ),
          ],
        ),
      ),
    );
  }
}
