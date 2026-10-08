import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../shared/models/enums.dart';
import '../../../../shared/models/event_item.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../../shared/widgets/tone.dart';
import '../../domain/providers.dart';

IconData _iconFor(EventType type) => switch (type) {
      EventType.mature => Icons.agriculture,
      EventType.tempLow => Icons.ac_unit,
      EventType.tempHigh => Icons.local_fire_department,
      EventType.heaterOn => Icons.local_fire_department,
      EventType.heaterOff => Icons.power_off,
      EventType.valveOpen => Icons.water_drop,
      EventType.valveClose => Icons.invert_colors_off,
      EventType.deviceOffline => Icons.wifi_off,
      EventType.deviceOnline => Icons.wifi,
      EventType.safetyCutoff => Icons.gpp_maybe,
    };

class EventTile extends ConsumerWidget {
  const EventTile({super.key, required this.event});

  final EventItem event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isMature = event.type == EventType.mature;
    final unread = !event.isRead;

    return Card(
      color: isMature ? theme.colorScheme.primaryContainer : null,
      child: ListTile(
        onTap: unread
            ? () => ref.read(eventsProvider.notifier).markRead(event.id)
            : null,
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          child: Icon(
            _iconFor(event.type),
            color: theme.colorScheme.primary,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                event.message,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: unread ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (unread)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(left: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              StatusBadge(
                label: event.type.label,
                tone: toneForSeverity(event.severity),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  Formatters.dateTime(event.createdAt),
                  style: theme.textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        isThreeLine: true,
      ),
    );
  }
}
