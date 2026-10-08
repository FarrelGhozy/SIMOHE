// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MetricStats _$MetricStatsFromJson(Map<String, dynamic> json) => _MetricStats(
  min: (json['min'] as num?)?.toDouble(),
  max: (json['max'] as num?)?.toDouble(),
  avg: (json['avg'] as num?)?.toDouble(),
);

Map<String, dynamic> _$MetricStatsToJson(_MetricStats instance) =>
    <String, dynamic>{
      'min': instance.min,
      'max': instance.max,
      'avg': instance.avg,
    };

_SummaryResponse _$SummaryResponseFromJson(Map<String, dynamic> json) =>
    _SummaryResponse(
      from: DateTime.parse(json['from'] as String),
      to: DateTime.parse(json['to'] as String),
      rangeCount: (json['range_count'] as num?)?.toInt() ?? 0,
      tempC: MetricStats.fromJson(json['temp_c'] as Map<String, dynamic>),
      nh3Ppm: MetricStats.fromJson(json['nh3_ppm'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SummaryResponseToJson(_SummaryResponse instance) =>
    <String, dynamic>{
      'from': instance.from.toIso8601String(),
      'to': instance.to.toIso8601String(),
      'range_count': instance.rangeCount,
      'temp_c': instance.tempC,
      'nh3_ppm': instance.nh3Ppm,
    };
