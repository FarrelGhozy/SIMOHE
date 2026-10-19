import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../../../shared/widgets/notification_bell.dart';
import '../../../shared/widgets/section_card.dart';
import '../domain/providers.dart';
import 'widgets/analysis_settings_card.dart';
import 'widgets/stability_gauge.dart';
import 'widgets/wave_chart.dart';

/// Tab Analisis (ikon tabung): % stabilitas gelombang NH3 sebagai
/// indikator kematangan pupuk. Dihitung full di HP dari data Supabase
/// dalam window yang diatur di halaman ini.
class AnalysisScreen extends ConsumerWidget {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analysis = ref.watch(analysisProvider);
    final notifier = ref.read(analysisProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analisis'),
        actions: [
          const NotificationBell(),
          IconButton(
            tooltip: 'Analisis sekarang',
            icon: const Icon(Icons.refresh),
            onPressed: () => notifier.refresh(),
          ),
        ],
      ),
      body: AsyncValueView<AnalysisData>(
        value: analysis,
        onRetry: notifier.refresh,
        builder: (data) => RefreshIndicator(
          onRefresh: notifier.refresh,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (data.gateReason != null)
                _GateBanner(message: data.gateReason!),
              if (data.gateReason != null) const SizedBox(height: 12),
              StabilityGauge(data: data),
              const SizedBox(height: 12),
              WaveChart(points: data.points),
              const SizedBox(height: 12),
              const AnalysisSettingsCard(),
              const SizedBox(height: 12),
              SectionCard(
                title: 'Catatan',
                child: Text(
                  'Stabilitas dihitung dari bentuk gelombang NH3 '
                  '(${data.windowMin} menit terakhir, dianalisis '
                  '${Formatters.time(data.analyzedAt)}). '
                  'Katup tetap manual: matang tidak pernah membuka katup '
                  'otomatis. Nilai nol / sensor mati tidak dinilai matang '
                  'dan tidak memicu notifikasi.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _GateBanner extends StatelessWidget {
  const _GateBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: theme.colorScheme.secondary),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}
