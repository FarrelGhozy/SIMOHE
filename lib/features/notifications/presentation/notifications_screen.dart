import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/event_item.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../domain/providers.dart';
import 'widgets/event_tile.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  bool _unreadOnly = false;

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
            onPressed: unread > 0 ? notifier.markAllRead : null,
          ),
        ],
      ),
      body: Column(
        children: [
          SwitchListTile(
            title: const Text('Hanya belum dibaca'),
            value: _unreadOnly,
            onChanged: (value) => setState(() => _unreadOnly = value),
          ),
          const Divider(height: 1),
          Expanded(
            child: AsyncValueView<EventsResponse>(
              value: events,
              onRetry: notifier.refresh,
              builder: (data) {
                final items = _unreadOnly
                    ? data.items.where((event) => !event.isRead).toList()
                    : data.items;
                if (items.isEmpty) {
                  return const Center(
                    child: Text('Tidak ada notifikasi.'),
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
