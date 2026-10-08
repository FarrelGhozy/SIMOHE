import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../shared/models/live_state.dart';
import '../../../../shared/widgets/metric_card.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../../shared/widgets/tone.dart';
import '../../../settings/domain/providers.dart';

class SensorMetrics extends ConsumerWidget {
  const SensorMetrics({super.key, required this.live});

  final LiveState live;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider).asData?.value;
    final tempMin = settings?.tempMinC ?? 30;
    final tempMax = settings?.tempMaxC ?? 45;

    final state = live.state;
    final temp = state.tempC;
    final nh3 = state.nh3Ppm;
    final threshold = live.maturity.thresholdPpm;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: MetricCard(
              title: 'Suhu air',
              value: Formatters.number(temp),
              unit: '°C',
              icon: Icons.thermostat,
              tone: toneForTemp(temp, tempMin, tempMax),
              subtitle: tempStatusLabel(temp, tempMin, tempMax),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: MetricCard(
              title: 'Gas NH3',
              value: Formatters.number(nh3),
              unit: 'ppm',
              icon: Icons.air,
              tone: nh3 == null
                  ? StatusTone.offline
                  : (nh3 >= threshold ? StatusTone.warning : StatusTone.normal),
              subtitle: 'Ambang ${Formatters.number(threshold)} ppm',
            ),
          ),
        ],
      ),
    );
  }
}
