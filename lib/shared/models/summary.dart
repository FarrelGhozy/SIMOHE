import 'package:freezed_annotation/freezed_annotation.dart';

part 'summary.freezed.dart';
part 'summary.g.dart';

@freezed
abstract class MetricStats with _$MetricStats {
  const factory MetricStats({
    double? min,
    double? max,
    double? avg,
  }) = _MetricStats;

  factory MetricStats.fromJson(Map<String, dynamic> json) =>
      _$MetricStatsFromJson(json);
}

@freezed
abstract class SummaryResponse with _$SummaryResponse {
  const factory SummaryResponse({
    required DateTime from,
    required DateTime to,
    @JsonKey(name: 'range_count') @Default(0) int rangeCount,
    @JsonKey(name: 'temp_c') required MetricStats tempC,
    @JsonKey(name: 'nh3_ppm') required MetricStats nh3Ppm,
  }) = _SummaryResponse;

  factory SummaryResponse.fromJson(Map<String, dynamic> json) =>
      _$SummaryResponseFromJson(json);
}
