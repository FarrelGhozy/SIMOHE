import '../../../core/network/providers.dart';
import '../../../shared/models/command.dart';
import '../../../shared/models/enums.dart';

/// Perintah katup/heater: baca langsung PostgREST, tulis via Edge Function
/// `app-command` (agar TTL/validasi tetap di sisi server).
class ControlRepository extends DeviceScopedRepository {
  ControlRepository(super.client);

  Future<CreateCommandResult> sendCommand(
    CommandAction action, {
    int? durationMin,
  }) async {
    final data = await invokeWrite(client, 'app-command', {
      'action': action.wireValue,
      if (durationMin != null) 'args': {'duration_min': durationMin},
    });
    return CreateCommandResult.fromJson(data);
  }

  Future<List<Command>> getCommands({
    CommandStatus? status,
    int limit = 50,
  }) async {
    final id = await deviceId();
    final filtered = status != null
        ? client.from('commands').select().eq('device_id', id).eq('status', status.name)
        : client.from('commands').select().eq('device_id', id);
    final rows = await guard(
      () => filtered.order('created_at', ascending: false).limit(limit),
    );
    return rows.map((item) {
      final row = Map<String, dynamic>.from(item as Map);
      row['args'] = toStringMap(row['payload']);
      return Command.fromJson(row);
    }).toList();
  }

  Future<void> cancelCommand(String id) async {
    await invokeWrite(client, 'app-command', {'op': 'cancel', 'id': id});
  }
}
