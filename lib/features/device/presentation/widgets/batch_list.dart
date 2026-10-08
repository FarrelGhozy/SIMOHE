import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../shared/models/batch.dart';
import '../../../../shared/models/enums.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../../shared/widgets/section_card.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../domain/providers.dart';

StatusTone _tone(BatchStatus status) => switch (status) {
      BatchStatus.fermenting => StatusTone.info,
      BatchStatus.mature => StatusTone.warning,
      BatchStatus.harvested => StatusTone.normal,
    };

class BatchList extends ConsumerWidget {
  const BatchList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final batches = ref.watch(batchesProvider);
    final notifier = ref.read(batchesProvider.notifier);

    return SectionCard(
      title: 'Siklus pengolahan',
      trailing: IconButton(
        tooltip: 'Muat ulang',
        icon: const Icon(Icons.refresh),
        onPressed: notifier.refresh,
      ),
      child: AsyncValueView<List<Batch>>(
        value: batches,
        onRetry: notifier.refresh,
        builder: (list) {
          if (list.isEmpty) {
            return const Text('Belum ada siklus.');
          }
          return Column(
            children: [
              for (final batch in list.take(10)) _BatchTile(batch: batch),
            ],
          );
        },
      ),
    );
  }
}

class _BatchTile extends StatelessWidget {
  const _BatchTile({required this.batch});

  final Batch batch;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.recycling),
      title: Text(batch.label ?? 'Siklus #${batch.id}'),
      subtitle: Text('Mulai ${Formatters.date(batch.startedAt)}'),
      trailing: StatusBadge(
        label: batch.status.label,
        tone: _tone(batch.status),
      ),
    );
  }
}
