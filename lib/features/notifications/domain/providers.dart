import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/providers.dart';
import '../../../shared/models/event_item.dart';
import '../data/notifications_repository.dart';

final notificationsRepositoryProvider = Provider<NotificationsRepository>(
  (ref) => NotificationsRepository(ref.watch(apiClientProvider)),
);

class EventsNotifier extends AsyncNotifier<EventsResponse> {
  Timer? _timer;

  @override
  Future<EventsResponse> build() async {
    _timer = Timer.periodic(
      const Duration(seconds: AppConfig.eventsPollIntervalSeconds),
      (_) => _poll(),
    );
    ref.onDispose(() => _timer?.cancel());
    return ref.read(notificationsRepositoryProvider).getEvents();
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
