import '../../../core/network/api_client.dart';
import '../../../shared/models/batch.dart';
import '../../../shared/models/device_detail.dart';

class DeviceRepository {
  DeviceRepository(this._client);

  final ApiClient _client;

  Future<DeviceDetail> getDevice() => _client.get(
        '/api/device',
        decode: (data) => DeviceDetail.fromJson(data as Map<String, dynamic>),
      );

  Future<List<Batch>> getBatches({int limit = 50}) => _client.get(
        '/api/batches',
        query: {'limit': limit},
        decode: (data) => (data as List<dynamic>)
            .map((item) => Batch.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
}
