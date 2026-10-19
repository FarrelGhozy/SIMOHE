import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/network/providers.dart';
import '../../../shared/models/event_item.dart';

/// Notifikasi: baca langsung PostgREST. Tandai dibaca via UPDATE kolom
/// `is_read` (dibatasi trigger DB: hanya kolom itu yang boleh berubah).
class NotificationsRepository extends DeviceScopedRepository {
  NotificationsRepository(super.client);

  Future<EventsResponse> getEvents({
    bool unreadOnly = false,
    int limit = 100,
  }) async {
    final id = await deviceId();
    final filtered = unreadOnly
        ? client.from('events').select().eq('device_id', id).eq('is_read', false)
        : client.from('events').select().eq('device_id', id);
    final rows = await guard(
      () => filtered.order('created_at', ascending: false).limit(limit),
    );

    final countResponse = await guard(
      () => client
          .from('events')
          .select('id')
          .eq('device_id', id)
          .eq('is_read', false)
          .limit(1)
          .count(CountOption.exact),
    );
    final unread = countResponse.count;

    return EventsResponse(
      items: rows.map((item) {
        final row = Map<String, dynamic>.from(item as Map);
        row['payload'] = toStringMap(row['payload']);
        return EventItem.fromJson(row);
      }).toList(),
      unreadCount: unread,
    );
  }

  Future<void> markRead(int id) async {
    final device = await deviceId();
    await guard(
      () => client
          .from('events')
          .update({'is_read': true})
          .eq('id', id)
          .eq('device_id', device),
    );
  }

  Future<void> markAllRead() async {
    final device = await deviceId();
    await guard(
      () => client.from('events').update({'is_read': true}).eq('device_id', device),
    );
  }
}
