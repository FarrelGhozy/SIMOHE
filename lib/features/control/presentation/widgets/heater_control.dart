import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../shared/models/enums.dart';
import '../../../../shared/widgets/app_segmented.dart';
import '../../../../shared/widgets/section_card.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../dashboard/domain/providers.dart';
import '../../../settings/domain/providers.dart';
import '../../domain/providers.dart';

class HeaterControl extends ConsumerWidget {
  const HeaterControl({super.key});

  Future<void> _send(
    BuildContext context,
    WidgetRef ref,
    CommandAction action, {
    int? durationMin,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final result = await ref
          .read(commandsProvider.notifier)
          .send(action, durationMin: durationMin);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Perintah "${result.action.label}" dikirim (${result.status.label}).',
          ),
        ),
      );
    } on ApiException catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text('Gagal: ${error.message}')),
      );
    }
  }

  Future<int?> _askDuration(BuildContext context, int defaultMinutes) async {
    final controller = TextEditingController(text: '$defaultMinutes');
    final value = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Durasi FORCE ON'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Durasi (menit)',
            suffixText: 'menit',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              final parsed = int.tryParse(controller.text);
              if (parsed != null && parsed > 0) {
                Navigator.of(context).pop(parsed);
              }
            },
            child: const Text('Kirim'),
          ),
        ],
      ),
    );
    controller.dispose();
    return value;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final live = ref.watch(liveProvider).asData?.value;
    final settings = ref.watch(settingsProvider).asData?.value;
    final mode = live?.state.mode ?? HeaterMode.auto;
    final heaterOn = live?.state.heaterOn ?? false;
    final ready = live != null;
    final tempMax = settings?.tempMaxC ?? 45;
    final maxOn = settings?.heaterMaxOnMin ?? 60;

    return SectionCard(
      title: 'Heater',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StatusBadge(
                label: heaterOn ? 'Menyala' : 'Mati',
                tone: heaterOn ? StatusTone.warning : StatusTone.offline,
                icon: Icons.local_fire_department,
              ),
              const Spacer(),
              Text(
                'Mode: ${mode.label}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: AppSegmented<HeaterMode>(
              expanded: true,
              segments: const [
                ButtonSegment(value: HeaterMode.auto, label: Text('AUTO')),
                ButtonSegment(value: HeaterMode.forceOn, label: Text('ON')),
                ButtonSegment(value: HeaterMode.forceOff, label: Text('OFF')),
              ],
              selected: {mode},
              onSelectionChanged: !ready
                  ? null
                  : (selection) async {
                      switch (selection.first) {
                        case HeaterMode.auto:
                          await _send(context, ref, CommandAction.heaterAuto);
                        case HeaterMode.forceOn:
                          final duration = await _askDuration(context, maxOn);
                          if (duration == null || !context.mounted) return;
                          await _send(
                            context,
                            ref,
                            CommandAction.heaterOn,
                            durationMin: duration,
                          );
                        case HeaterMode.forceOff:
                          await _send(context, ref, CommandAction.heaterOff);
                      }
                    },
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Safety: heater mati otomatis bila suhu ≥ $tempMax °C atau '
            'menyala lebih dari $maxOn menit.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
