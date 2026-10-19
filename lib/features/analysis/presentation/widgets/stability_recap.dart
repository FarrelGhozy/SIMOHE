import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/section_card.dart';
import '../../data/stability_calc.dart';
import '../../domain/providers.dart';

/// Rekapan ringkas hasil analisis stabilitas untuk Dashboard.
/// Ketuk → pindah ke tab Analisis.
class StabilityRecap extends ConsumerWidget {
  const StabilityRecap({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analysis = ref.watch(analysisProvider);
    final theme = Theme.of(context);

    return SectionCard(
      title: 'Stabilitas NH3',
      child: analysis.when(
        loading: () => const SizedBox(
          height: 48,
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (error, _) => Text(
          'Analisis belum tersedia. Buka tab Analisis untuk menghitung.',
          style: theme.textTheme.bodyMedium,
        ),
        data: (data) {
          final s = data.stability;
          final String text;
          final IconData icon;
          switch (s.status) {
            case StabilityStatus.ok:
              text = data.mature
                  ? 'Matang — stabil ${s.percent!.toStringAsFixed(0)}% (ambang '
                      '${data.thresholdPct.toStringAsFixed(0)}%)'
                  : 'Stabil ${s.percent!.toStringAsFixed(0)}% • '
                      '${s.valid} titik / ${data.windowMin} mnt';
              icon = data.mature
                  ? Icons.check_circle
                  : Icons.science_outlined;
            case StabilityStatus.dataKurang:
              text = 'Data kurang — perlu ${s.valid} titik valid lagi.';
              icon = Icons.cloud_off;
            case StabilityStatus.invalidNol:
            case StabilityStatus.sensorMacet:
              text = 'Sensor NH3 bermasalah — periksa perangkat.';
              icon = Icons.sensors_off;
          }
          return InkWell(
            onTap: () => context.go('/analysis'),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(icon, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(child: Text(text)),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
