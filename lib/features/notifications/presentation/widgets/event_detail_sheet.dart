import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../shared/models/enums.dart';
import '../../../../shared/models/event_item.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../../shared/widgets/tone.dart';
import '../../domain/providers.dart';

/// Aksi kontekstual per jenis event.
({String label, IconData icon, String route}) _actionFor(EventType type) =>
    switch (type) {
      EventType.mature => (
          label: 'Buka Kontrol katup',
          icon: Icons.tune,
          route: '/control',
        ),
      EventType.tempLow ||
      EventType.tempHigh ||
      EventType.safetyCutoff =>
        (
          label: 'Lihat Dashboard',
          icon: Icons.dashboard_outlined,
          route: '/dashboard',
        ),
      EventType.deviceOffline || EventType.deviceOnline => (
          label: 'Lihat Perangkat',
          icon: Icons.router_outlined,
          route: '/device',
        ),
      EventType.heaterOn ||
      EventType.heaterOff ||
      EventType.valveOpen ||
      EventType.valveClose =>
        (label: 'Buka Kontrol', icon: Icons.tune, route: '/control'),
    };

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

Future<void> showEventDetailSheet(
  BuildContext context,
  EventItem event,
) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => EventDetailSheet(event: event),
  );
}

class EventDetailSheet extends ConsumerStatefulWidget {
  const EventDetailSheet({super.key, required this.event});

  final EventItem event;

  @override
  ConsumerState<EventDetailSheet> createState() => _EventDetailSheetState();
}

class _EventDetailSheetState extends ConsumerState<EventDetailSheet> {
  late bool _markedRead;

  @override
  void initState() {
    super.initState();
    _markedRead = widget.event.isRead;
    if (!widget.event.isRead) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _markRead());
    }
  }

  Future<void> _markRead() async {
    try {
      await ref.read(eventsProvider.notifier).markRead(widget.event.id);
      if (mounted) setState(() => _markedRead = true);
    } on Object {
      // Biarkan tombol "Tandai dibaca" untuk mencoba ulang.
    }
  }

  void _navigate(String route) {
    final router = GoRouter.of(context);
    Navigator.of(context).pop();
    router.go(route);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final event = widget.event;
    final action = _actionFor(event.type);
    final payload = event.payload.entries
        .where((entry) => entry.value is! Map && entry.value is! List)
        .toList();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  child: Icon(_iconFor(event.type), color: theme.colorScheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(event.type.label, style: theme.textTheme.titleMedium),
                      const SizedBox(height: 2),
                      Text(
                        Formatters.dateTime(event.createdAt),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                StatusBadge(
                  label: event.severity.label,
                  tone: toneForSeverity(event.severity),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(event.message, style: theme.textTheme.bodyLarge),
            if (payload.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final entry in payload)
                    Chip(
                      label: Text(
                        '${_prettify(entry.key)}: ${entry.value}',
                        style: theme.textTheme.bodySmall,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            if (!_markedRead)
              Row(
                children: [
                  Icon(Icons.circle_outlined,
                      size: 16, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Belum dibaca',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                  TextButton(
                    onPressed: _markRead,
                    child: const Text('Tandai dibaca'),
                  ),
                ],
              )
            else
              Row(
                children: [
                  Icon(Icons.check_circle,
                      size: 16, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Ditandai dibaca',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.primary),
                  ),
                ],
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _navigate(action.route),
                    icon: Icon(action.icon),
                    label: Text(action.label),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Tutup'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _prettify(String key) => key.replaceAll('_', ' ');
}
