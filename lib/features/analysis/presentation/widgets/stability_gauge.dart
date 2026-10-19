import 'package:flutter/material.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/section_card.dart';
import '../../data/stability_calc.dart';
import '../../domain/providers.dart';

/// Kartu gauge % stabilitas + angka tabung (min/max/range/std/n).
class StabilityGauge extends StatelessWidget {
  const StabilityGauge({super.key, required this.data});

  final AnalysisData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = data.stability;

    return SectionCard(
      title: 'Stabilitas NH3',
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: CircularProgressIndicator(
                        value: s.status == StabilityStatus.ok
                            ? (s.percent! / 100).clamp(0.0, 1.0)
                            : 0,
                        strokeWidth: 12,
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
                      ),
                    ),
                    Text(
                      s.status == StabilityStatus.ok
                          ? '${s.percent!.toStringAsFixed(0)}%'
                          : '—',
                      style: theme.textTheme.headlineMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(child: _StatusText(data: data)),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 4,
            children: [
              _Stat(label: 'Titik', value: '${s.valid}/${s.total}'),
              _Stat(
                label: 'Rata-rata',
                value: '${Formatters.number(s.mean)} ppm',
              ),
              _Stat(
                label: 'Tabung',
                value: s.range == null
                    ? '-'
                    : '${Formatters.number(s.min)}–${Formatters.number(s.max)} ppm',
              ),
              _Stat(
                label: 'Lebar',
                value: s.range == null
                    ? '-'
                    : '${Formatters.number(s.range)} ppm',
              ),
              _Stat(
                label: 'Std',
                value: '${Formatters.number(s.std)} ppm',
              ),
              _Stat(label: 'Window', value: '${data.windowMin} mnt'),
              _Stat(
                label: 'Sumber',
                value: data.fromRaw ? 'raw' : '15 mnt',
              ),
            ],
          ),
          if (!data.fromRaw) ...[
            const SizedBox(height: 8),
            Text(
              'Data rapat tidak cukup — memakai histori 15-menit. '
              'Hasil kurang presisi untuk gelombang pendek.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusText extends StatelessWidget {
  const _StatusText({required this.data});

  final AnalysisData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = data.stability;

    final String text;
    final IconData icon;
    final Color color;
    switch (s.status) {
      case StabilityStatus.ok:
        if (data.mature) {
          text =
              'Pupuk matang (stabil ${s.percent!.toStringAsFixed(0)}% ≥ '
              '${data.thresholdPct.toStringAsFixed(0)}%). Buka katup dari '
              'aplikasi bila sudah waktunya.';
          icon = Icons.check_circle;
          color = theme.colorScheme.primary;
        } else {
          text =
              'Belum matang — stabil ${s.percent!.toStringAsFixed(0)}% dari '
              'ambang ${data.thresholdPct.toStringAsFixed(0)}%. Makin pipih '
              'tabung gelombang, makin tinggi %.';
          icon = Icons.hourglass_bottom;
          color = theme.colorScheme.secondary;
        }
      case StabilityStatus.dataKurang:
        text =
            'Data kurang (${s.valid} titik valid). Perlebar window atau '
            'tunggu kiriman perangkat berikutnya.';
        icon = Icons.cloud_off;
        color = theme.colorScheme.error;
      case StabilityStatus.invalidNol:
        text =
            'Nilai NH3 nol — sensor diduga mati / belum preheat. '
            'Tidak dinilai matang, tidak ada notifikasi.';
        icon = Icons.sensors_off;
        color = theme.colorScheme.error;
      case StabilityStatus.sensorMacet:
        text =
            'Nilai NH3 identik persis — sensor diduga macet. '
            'Tidak dinilai matang, tidak ada notifikasi.';
        icon = Icons.sensors_off;
        color = theme.colorScheme.error;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: theme.textTheme.labelSmall),
        Text(value, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}
