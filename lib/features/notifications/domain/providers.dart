import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/providers.dart';
import '../../../shared/models/event_item.dart';
import '../data/notifications_repository.dart';

final notificationsRepositoryProvider = Provider<NotificationsRepository>(
  (ref) => NotificationsRepository(ref.watch(supabaseClientProvider)),
);

class EventsNotifier extends AsyncNotifier<EventsResponse> {
  Timer? _timer;
  RealtimeChannel? _channel;

  @override
  Future<EventsResponse> build() async {
    _timer = Timer.periodic(
      const Duration(seconds: AppConfig.eventsPollIntervalSeconds),
      (_) => _poll(),
    );
    ref.onDispose(() => _timer?.cancel());
    _subscribeRealtime();
    return ref.read(notificationsRepositoryProvider).getEvents();
  }

  /// Realtime sebagai pelengkap polling; diabaikan bila Supabase belum
  /// siap (mis. unit test) — polling tetap jalan sebagai fallback.
  void _subscribeRealtime() {
    try {
      final client = ref.read(supabaseClientProvider);
      _channel = client.channel('events-feed')
        ..onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'events',
          callback: (_) => _poll(),
        )
        ..subscribe();
      ref.onDispose(() {
        final channel = _channel;
        if (channel != null) unawaited(client.removeChannel(channel));
      });
    } on Object {
      _channel = null;
    }
  }

  Future<void> _poll() async {
    try {
      state = AsyncData(
        await ref.read(notificationsRepositoryProvider).getEvents(),
      );
    } on Object {
      // Pertahankan daftar terakhir saat polling gagal.
    }
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(
      () => ref.read(notificationsRepositoryProvider).getEvents(),
    );
  }

  Future<void> markRead(int id) async {
    await ref.read(notificationsRepositoryProvider).markRead(id);
    await refresh();
  }

  Future<void> markAllRead() async {
    await ref.read(notificationsRepositoryProvider).markAllRead();
    await refresh();
  }
}

final eventsProvider = AsyncNotifierProvider<EventsNotifier, EventsResponse>(
  EventsNotifier.new,
);

final unreadCountProvider = Provider<int>((ref) {
  final events = ref.watch(eventsProvider).asData?.value;
  return events?.unreadCount ?? 0;
});
