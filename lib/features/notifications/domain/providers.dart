import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/notification_prefs.dart';
import '../../../core/config/refresh_settings.dart';
import '../../../core/network/providers.dart';
import '../../../shared/models/event_item.dart';
import '../data/local_notification_service.dart';
import '../data/notifications_repository.dart';

final notificationsRepositoryProvider = Provider<NotificationsRepository>(
  (ref) => NotificationsRepository(ref.watch(supabaseClientProvider)),
);

/// Di-override di `main()` dengan instance yang sudah `init()`.
final localNotificationServiceProvider = Provider<LocalNotificationService>(
  (ref) => LocalNotificationService(),
);

class EventsNotifier extends AsyncNotifier<EventsResponse> {
  static const String _lastSeenKey = 'notif.last_seen_event_id';

  Timer? _timer;
  RealtimeChannel? _channel;

  @override
  Future<EventsResponse> build() async {
    _restartTimer();
    ref.listen(refreshSettingsProvider, (_, _) => _restartTimer());
    ref.onDispose(() => _timer?.cancel());
    _subscribeRealtime();
    return _fetch();
  }

  void _restartTimer() {
    _timer?.cancel();
    final interval = ref.read(refreshSettingsProvider).events;
    _timer = Timer.periodic(interval, (_) => _poll());
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

  Future<EventsResponse> _fetch({bool notify = true}) async {
    final response = await ref.read(notificationsRepositoryProvider).getEvents();
    if (notify) await _notifyNew(response.items);
    return response;
  }

  /// Tampilkan notifikasi sistem untuk event baru (id > terakhir dilihat).
  /// Pemuatan pertama hanya menyimpan penanda agar histori lama tidak
  /// memicu banjir notifikasi.
  Future<void> _notifyNew(List<EventItem> items) async {
    if (items.isEmpty) return;
    final prefs = ref.read(sharedPreferencesProvider);
    final maxId = items.map((event) => event.id).reduce((a, b) => a > b ? a : b);
    final lastSeen = prefs.getInt(_lastSeenKey);
    if (lastSeen == null) {
      await prefs.setInt(_lastSeenKey, maxId);
      return;
    }
    if (maxId <= lastSeen) return;

    final settings = ref.read(notificationPrefsProvider);
    if (settings.enabled) {
      final service = ref.read(localNotificationServiceProvider);
      final fresh = items.where((event) => event.id > lastSeen).toList()
        ..sort((a, b) => a.id.compareTo(b.id));
      for (final event in fresh) {
        if (settings.allows(event.severity)) {
          await service.showEvent(event);
        }
      }
    }
    await prefs.setInt(_lastSeenKey, maxId);
  }

  Future<void> _poll() async {
    try {
      state = AsyncData(await _fetch());
    } on Object {
      // Pertahankan daftar terakhir saat polling gagal.
    }
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(() => _fetch());
  }

  Future<void> markRead(int id) async {
    final current = state.asData?.value;
    if (current != null) {
      final wasUnread = current.items.any((e) => e.id == id && !e.isRead);
      state = AsyncData(
        current.copyWith(
          items: [
            for (final event in current.items)
              event.id == id ? event.copyWith(isRead: true) : event,
          ],
          unreadCount: wasUnread
              ? (current.unreadCount - 1).clamp(0, 1 << 31)
              : current.unreadCount,
        ),
      );
    }
    try {
      await ref.read(notificationsRepositoryProvider).markRead(id);
    } on Object {
      await refresh();
      rethrow;
    }
  }

  Future<void> markAllRead() async {
    final current = state.asData?.value;
    if (current != null) {
      state = AsyncData(
        current.copyWith(
          items: [for (final event in current.items) event.copyWith(isRead: true)],
          unreadCount: 0,
        ),
      );
    }
    try {
      await ref.read(notificationsRepositoryProvider).markAllRead();
    } on Object {
      await refresh();
      rethrow;
    }
  }
}

final eventsProvider = AsyncNotifierProvider<EventsNotifier, EventsResponse>(
  EventsNotifier.new,
);

final unreadCountProvider = Provider<int>((ref) {
  final events = ref.watch(eventsProvider).asData?.value;
  return events?.unreadCount ?? 0;
});
