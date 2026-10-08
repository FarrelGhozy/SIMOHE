import '../../../core/network/api_client.dart';
import '../../../shared/models/command.dart';
import '../../../shared/models/enums.dart';

class ControlRepository {
  ControlRepository(this._client);

  final ApiClient _client;

  Future<CreateCommandResult> sendCommand(
    CommandAction action, {
    int? durationMin,
  }) =>
      _client.post(
        '/api/commands',
        body: {
          'action': action.wireValue,
          if (durationMin != null) 'args': {'duration_min': durationMin},
        },
        decode: (data) =>
            CreateCommandResult.fromJson(data as Map<String, dynamic>),
      );

  Future<List<Command>> getCommands({
    CommandStatus? status,
    int limit = 50,
  }) =>
      _client.get(
        '/api/commands',
        query: {
          if (status != null) 'status': status.name,
          'limit': limit,
        },
        decode: (data) => (data as List<dynamic>)
            .map((item) => Command.fromJson(item as Map<String, dynamic>))
            .toList(),
      );

  Future<void> cancelCommand(String id) => _client.post(
        '/api/commands/$id/cancel',
        decode: (_) {},
      );
}
