import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/providers.dart';
import '../../../shared/models/enums.dart';
import '../../../shared/models/reading.dart';
import '../../../shared/models/summary.dart';
import '../data/history_repository.dart';

enum HistoryRange {
  last24h('24 jam', '24h', ReadingBucket.m15, Duration(hours: 24)),
  last7d('7 hari', '7d', ReadingBucket.h1, Duration(days: 7)),
  last30d('30 hari', '30d', ReadingBucket.h1, Duration(days: 30));

  const HistoryRange(this.label, this.summaryRange, this.bucket, this.window);

  final String label;
  final String summaryRange;
  final ReadingBucket bucket;
  final Duration window;
}

class HistoryData {
  const HistoryData({required this.readings, required this.summary});

  final ReadingsResponse readings;
  final SummaryResponse summary;
}

final historyRepositoryProvider = Provider<HistoryRepository>(
  (ref) => HistoryRepository(ref.watch(apiClientProvider)),
);

class HistoryNotifier extends AsyncNotifier<HistoryData> {
  HistoryRange _range = HistoryRange.last24h;

  HistoryRange get range => _range;

  @override
  Future<HistoryData> build() => _load(_range);

  Future<HistoryData> _load(HistoryRange range) async {
    final repository = ref.read(historyRepositoryProvider);
    final now = DateTime.now().toUtc();
    final readings = repository.getReadings(
      from: now.subtract(range.window),
      to: now,
      bucket: range.bucket,
    );
    final summary = repository.getSummary(range.summaryRange);
    return HistoryData(readings: await readings, summary: await summary);
  }

  Future<void> setRange(HistoryRange range) async {
    _range = range;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _load(range));
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(() => _load(_range));
  }
}

final historyProvider = AsyncNotifierProvider<HistoryNotifier, HistoryData>(
  HistoryNotifier.new,
);
