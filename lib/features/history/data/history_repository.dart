import '../../../core/network/api_client.dart';
import '../../../shared/models/enums.dart';
import '../../../shared/models/reading.dart';
import '../../../shared/models/summary.dart';

class HistoryRepository {
  HistoryRepository(this._client);

  final ApiClient _client;

  Future<ReadingsResponse> getReadings({
    required DateTime from,
    required DateTime to,
    required ReadingBucket bucket,
    int limit = 1000,
  }) =>
      _client.get(
        '/api/readings',
        query: {
          'from': from.toUtc().toIso8601String(),
          'to': to.toUtc().toIso8601String(),
          'bucket': bucket.wireValue,
          'limit': limit,
        },
        decode: (data) =>
            ReadingsResponse.fromJson(data as Map<String, dynamic>),
      );

  Future<SummaryResponse> getSummary(String range) => _client.get(
        '/api/summary',
        query: {'range': range},
        decode: (data) =>
            SummaryResponse.fromJson(data as Map<String, dynamic>),
      );
}
