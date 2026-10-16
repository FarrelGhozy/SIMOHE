import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/analysis_settings.dart';
import '../../../../shared/widgets/app_segmented.dart';
import '../../../../shared/widgets/section_card.dart';

/// Pengaturan interval & ambang analisis (lokal per perangkat).
class AnalysisSettingsCard extends ConsumerWidget {
  const AnalysisSettingsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(analysisSettingsProvider);
    final notifier = ref.read(analysisSettingsProvider.notifier);

    Future<void> save(AnalysisSettings next) => notifier.save(next);

    return SectionCard(
      title: 'Pengaturan analisis',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Window pengambilan data', style: _label(context)),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: AppSegmented<int>(
              segments: [
                for (final m in AnalysisSettings.windowPresets)
                  ButtonSegment(value: m, label: Text('$m mnt')),
              ],
              selected: {settings.windowMin},
              onSelectionChanged: (selected) =>
                  save(settings.copyWith(windowMin: selected.first)),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Ambang matang: ${settings.thresholdPct.toStringAsFixed(0)}%',
            style: _label(context),
          ),
          Slider(
            value: settings.thresholdPct,
            min: 50,
            max: 98,
            divisions: 48,
            label: '${settings.thresholdPct.toStringAsFixed(0)}%',
            onChanged: (value) =>
                save(settings.copyWith(thresholdPct: value)),
          ),
          Text(
            'Toleransi tabung: ${settings.rangeMaxPpm.toStringAsFixed(0)} ppm '
            '(lebar yang dianggap 0% stabil)',
            style: _label(context),
          ),
          Slider(
            value: settings.rangeMaxPpm,
            min: 2,
            max: 30,
            divisions: 28,
            label: '${settings.rangeMaxPpm.toStringAsFixed(0)} ppm',
            onChanged: (value) =>
                save(settings.copyWith(rangeMaxPpm: value)),
          ),
          Text('Cek otomatis', style: _label(context)),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: AppSegmented<int>(
              segments: [
                for (final s in AnalysisSettings.autoCheckPresets)
                  ButtonSegment(value: s, label: Text('${s ~/ 60} mnt')),
              ],
              selected: {settings.autoCheckSec},
              onSelectionChanged: (selected) =>
                  save(settings.copyWith(autoCheckSec: selected.first)),
            ),
          ),
        ],
      ),
    );
  }

  TextStyle? _label(BuildContext context) =>
      Theme.of(context).textTheme.labelMedium;
}
