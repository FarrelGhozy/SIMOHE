import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../shared/models/enums.dart';
import '../../../../shared/models/live_state.dart';
import '../../../../shared/widgets/section_card.dart';
import '../../../control/domain/providers.dart';
import '../../../settings/domain/providers.dart';

class QuickControls extends ConsumerWidget {
  const QuickControls({super.key, required this.live});

  final LiveState live;

  Future<void> _send(
    BuildContext context,
    WidgetRef ref,
    CommandAction action,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final result =
          await ref.read(commandsProvider.notifier).send(action);
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

  Future<void> _toggleValve(BuildContext context, WidgetRef ref) async {
    final open = live.state.valveOpen;
    final maxOpen = ref.read(settingsProvider).asData?.value.valveMaxOpenMin ?? 10;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(open ? 'Tutup katup?' : 'Buka katup?'),
        content: Text(
          open
              ? 'Katup akan ditutup. Pastikan penampung siap.'
              : 'Katup akan dibuka. Katup tertutup otomatis setelah '
                  '$maxOpen menit (safety).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Lanjut'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!context.mounted) return;
    await _send(
      context,
      ref,
      open ? CommandAction.valveClose : CommandAction.valveOpen,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = live.state;
    return SectionCard(
      title: 'Kontrol cepat',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FilledButton.tonalIcon(
            onPressed: () => _toggleValve(context, ref),
            icon: Icon(state.valveOpen ? Icons.invert_colors_off : Icons.water_drop),
            label: Text(state.valveOpen ? 'Tutup katup' : 'Buka katup'),
          ),
          const SizedBox(height: 16),
          Text('Mode heater', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          SegmentedButton<HeaterMode>(
            segments: const [
              ButtonSegment(
                value: HeaterMode.auto,
                label: Text('AUTO'),
                icon: Icon(Icons.autorenew),
              ),
              ButtonSegment(
                value: HeaterMode.forceOn,
                label: Text('ON'),
                icon: Icon(Icons.power_settings_new),
              ),
              ButtonSegment(
                value: HeaterMode.forceOff,
                label: Text('OFF'),
                icon: Icon(Icons.block),
              ),
            ],
            selected: {state.mode},
            onSelectionChanged: (selection) {
              final action = switch (selection.first) {
                HeaterMode.auto => CommandAction.heaterAuto,
                HeaterMode.forceOn => CommandAction.heaterOn,
                HeaterMode.forceOff => CommandAction.heaterOff,
              };
              _send(context, ref, action);
            },
          ),
        ],
      ),
    );
  }
}
