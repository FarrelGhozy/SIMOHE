import '../../../core/network/api_client.dart';
import '../../../shared/models/settings.dart';

class SettingsRepository {
  SettingsRepository(this._client);

  final ApiClient _client;

  Future<AppSettings> getSettings() => _client.get(
        '/api/settings',
        decode: (data) => AppSettings.fromJson(data as Map<String, dynamic>),
      );

  Future<AppSettings> updateSettings(SettingsPatch patch) => _client.put(
        '/api/settings',
        body: patch.toJson(),
        decode: (data) => AppSettings.fromJson(data as Map<String, dynamic>),
      );
}
