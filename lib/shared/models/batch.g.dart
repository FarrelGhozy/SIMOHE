// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'batch.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Batch _$BatchFromJson(Map<String, dynamic> json) => _Batch(
  id: (json['id'] as num).toInt(),
  label: json['label'] as String?,
  status: $enumDecode(_$BatchStatusEnumMap, json['status']),
  startedAt: json['started_at'] == null
      ? null
      : DateTime.parse(json['started_at'] as String),
  maturedAt: json['matured_at'] == null
      ? null
      : DateTime.parse(json['matured_at'] as String),
  harvestedAt: json['harvested_at'] == null
      ? null
      : DateTime.parse(json['harvested_at'] as String),
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$BatchToJson(_Batch instance) => <String, dynamic>{
  'id': instance.id,
  'label': instance.label,
  'status': _$BatchStatusEnumMap[instance.status]!,
  'started_at': instance.startedAt?.toIso8601String(),
  'matured_at': instance.maturedAt?.toIso8601String(),
  'harvested_at': instance.harvestedAt?.toIso8601String(),
  'created_at': instance.createdAt?.toIso8601String(),
};

const _$BatchStatusEnumMap = {
  BatchStatus.fermenting: 'fermenting',
  BatchStatus.mature: 'mature',
  BatchStatus.harvested: 'harvested',
};
