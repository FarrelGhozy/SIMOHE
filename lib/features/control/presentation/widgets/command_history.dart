import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/models/command.dart';
import '../../../../shared/models/enums.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../../shared/widgets/section_card.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../../shared/widgets/tone.dart';
import '../../domain/providers.dart';

class CommandHistory extends ConsumerWidget {
  const CommandHistory({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commands = ref.watch(commandsProvider);
    final notifier = ref.read(commandsProvider.notifier);

    return SectionCard(
      title: 'Riwayat perintah',
      trailing: IconButton(
        tooltip: 'Muat ulang',
        icon: const Icon(Icons.refresh),
        onPressed: notifier.refresh,
      ),
      child: AsyncValueView<List<Command>>(
        value: commands,
        onRetry: notifier.refresh,
        builder: (list) {
          if (list.isEmpty) {
            return const Text('Belum ada perintah.');
          }
          return Column(
            children: [
              for (final command in list.take(8))
                _CommandTile(command: command),
            ],
          );
        },
      ),
    );
  }
}

class _CommandTile extends ConsumerWidget {
  const _CommandTile({required this.command});

  final Command command;

  Future<void> _cancel(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(commandsProvider.notifier).cancel(command.id);
    } on ApiException catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text('Gagal membatalkan: ${error.message}')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.history),
      title: Text(command.action.label),
      subtitle: Text(Formatters.dateTime(command.createdAt)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          StatusBadge(
            label: command.status.label,
            tone: toneForCommandStatus(command.status),
          ),
          if (command.status == CommandStatus.pending)
            IconButton(
              tooltip: 'Batalkan',
              icon: const Icon(Icons.close),
              onPressed: () => _cancel(context, ref),
            ),
        ],
      ),
    );
  }
}
