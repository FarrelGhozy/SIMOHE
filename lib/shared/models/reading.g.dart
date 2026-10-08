// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ReadingPoint _$ReadingPointFromJson(Map<String, dynamic> json) =>
    _ReadingPoint(
      ts: json['ts'] == null ? null : DateTime.parse(json['ts'] as String),
      tempC: (json['temp_c'] as num?)?.toDouble(),
      nh3Ppm: (json['nh3_ppm'] as num?)?.toDouble(),
      heaterOn: json['heater_on'] as bool,
      valveOpen: json['valve_open'] as bool,
    );

Map<String, dynamic> _$ReadingPointToJson(_ReadingPoint instance) =>
    <String, dynamic>{
      'ts': instance.ts?.toIso8601String(),
      'temp_c': instance.tempC,
      'nh3_ppm': instance.nh3Ppm,
      'heater_on': instance.heaterOn,
      'valve_open': instance.valveOpen,
    };

_ReadingsResponse _$ReadingsResponseFromJson(Map<String, dynamic> json) =>
    _ReadingsResponse(
      bucket: $enumDecode(_$ReadingBucketEnumMap, json['bucket']),
      from: json['from'] == null
          ? null
          : DateTime.parse(json['from'] as String),
      to: json['to'] == null ? null : DateTime.parse(json['to'] as String),
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => ReadingPoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <ReadingPoint>[],
    );

Map<String, dynamic> _$ReadingsResponseToJson(_ReadingsResponse instance) =>
    <String, dynamic>{
      'bucket': _$ReadingBucketEnumMap[instance.bucket]!,
      'from': instance.from?.toIso8601String(),
      'to': instance.to?.toIso8601String(),
      'items': instance.items,
    };

const _$ReadingBucketEnumMap = {
  ReadingBucket.raw: 'raw',
  ReadingBucket.m15: '15m',
  ReadingBucket.h1: '1h',
};
