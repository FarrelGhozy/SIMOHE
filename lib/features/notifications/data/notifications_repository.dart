import '../../../core/network/api_client.dart';
import '../../../shared/models/event_item.dart';

class NotificationsRepository {
  NotificationsRepository(this._client);

  final ApiClient _client;

  Future<EventsResponse> getEvents({bool unreadOnly = false, int limit = 100}) =>
      _client.get(
        '/api/events',
        query: {
          if (unreadOnly) 'unread': true,
          'limit': limit,
        },
        decode: (data) =>
            EventsResponse.fromJson(data as Map<String, dynamic>),
      );

  Future<void> markRead(int id) => _client.post(
        '/api/events/$id/read',
        decode: (_) {},
      );

  Future<void> markAllRead() => _client.post(
        '/api/events/read-all',
        decode: (_) {},
      );
}
