import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/providers.dart';
import '../../../shared/models/event_item.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../domain/providers.dart';
import 'widgets/event_detail_sheet.dart';
import 'widgets/event_tile.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key, this.highlightId});

  /// `events.id` yang ditekankan (mis. dari tap notifikasi sistem).
  final int? highlightId;

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  static const String _unreadOnlyKey = 'prefs.notifications.unread_only';

  bool _unreadOnly = false;
  bool _highlightHandled = false;

  @override
  void initState() {
    super.initState();
    _unreadOnly =
        ref.read(sharedPreferencesProvider).getBool(_unreadOnlyKey) ?? false;
  }

  void _setUnreadOnly(bool value) {
    setState(() => _unreadOnly = value);
    ref.read(sharedPreferencesProvider).setBool(_unreadOnlyKey, value);
  }

  Future<void> _confirmMarkAllRead(int unread) async {
    final notifier = ref.read(eventsProvider.notifier);
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Tandai semua dibaca?'),
        content: Text('$unread notifikasi akan ditandai sudah dibaca.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Tandai semua'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await notifier.markAllRead();
      messenger.showSnackBar(
        SnackBar(content: Text('$unread notifikasi ditandai dibaca.')),
      );
    } on Object {
      messenger.showSnackBar(
        const SnackBar(content: Text('Gagal menandai dibaca. Coba lagi.')),
      );
    }
  }

  void _handleHighlight(EventsResponse data) {
    if (_highlightHandled) return;
    final id = widget.highlightId;
    if (id == null) {
      _highlightHandled = true;
      return;
    }
    EventItem? match;
    for (final event in data.items) {
      if (event.id == id) {
        match = event;
        break;
      }
    }
    _highlightHandled = true;
    if (match == null) return;
    final event = match;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) showEventDetailSheet(context, event);
    });
  }

  @override
  Widget build(BuildContext context) {
    final events = ref.watch(eventsProvider);
    final notifier = ref.read(eventsProvider.notifier);
    final unread = ref.watch(unreadCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        actions: [
          IconButton(
            tooltip: 'Tandai semua dibaca',
            icon: const Icon(Icons.done_all),
            onPressed: unread > 0 ? () => _confirmMarkAllRead(unread) : null,
          ),
        ],
      ),
      body: Column(
        children: [
          SwitchListTile(
            title: const Text('Hanya belum dibaca'),
            value: _unreadOnly,
            onChanged: _setUnreadOnly,
          ),
          const Divider(height: 1),
          Expanded(
            child: AsyncValueView<EventsResponse>(
              value: events,
              onRetry: notifier.refresh,
              builder: (data) {
                _handleHighlight(data);
                final items = _unreadOnly
                    ? data.items.where((event) => !event.isRead).toList()
                    : data.items;
                if (items.isEmpty) {
                  return _EmptyState(
                    unreadOnly: _unreadOnly,
                    hasAny: data.items.isNotEmpty,
                  );
                }
                return RefreshIndicator(
                  onRefresh: notifier.refresh,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: items.length,
                    itemBuilder: (context, index) =>
                        EventTile(event: items[index]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.unreadOnly, required this.hasAny});

  final bool unreadOnly;
  final bool hasAny;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allRead = unreadOnly && hasAny;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              allRead ? Icons.task_alt : Icons.notifications_none,
              size: 48,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              allRead ? 'Semua sudah dibaca.' : 'Tidak ada notifikasi.',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              allRead
                  ? 'Notifikasi baru akan muncul di sini.'
                  : 'Peristiwa penting perangkat akan tampil di sini.',
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
