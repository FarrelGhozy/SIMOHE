import '../../../core/network/api_client.dart';
import '../../../shared/models/live_state.dart';

class DashboardRepository {
  DashboardRepository(this._client);

  final ApiClient _client;

  Future<LiveState> getLive() => _client.get(
        '/api/live',
        decode: (data) => LiveState.fromJson(data as Map<String, dynamic>),
      );
}
