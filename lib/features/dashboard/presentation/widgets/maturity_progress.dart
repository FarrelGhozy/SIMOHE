import 'package:flutter/material.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../shared/models/live_state.dart';
import '../../../../shared/widgets/section_card.dart';

class MaturityProgress extends StatelessWidget {
  const MaturityProgress({super.key, required this.live});

  final LiveState live;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maturity = live.maturity;

    return SectionCard(
      title: 'Kematangan pupuk',
      child: maturity.mature
          ? Row(
              children: [
                Icon(Icons.check_circle, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Pupuk siap/matang. Buka katup dari aplikasi bila sudah waktunya.',
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: maturity.progress,
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${Formatters.percent(maturity.progress)} • '
                  '${(maturity.streakSec / 60).floor()} / '
                  '${maturity.holdMinutes} menit bertahan',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  'NH3 ≥ ${Formatters.number(maturity.thresholdPpm)} ppm harus '
                  'bertahan ${maturity.holdMinutes} menit.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
    );
  }
}
