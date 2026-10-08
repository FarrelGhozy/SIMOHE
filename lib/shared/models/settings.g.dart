// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppSettings _$AppSettingsFromJson(Map<String, dynamic> json) => _AppSettings(
  id: (json['id'] as num).toInt(),
  deviceId: (json['device_id'] as num).toInt(),
  historyIntervalMin: (json['history_interval_min'] as num).toInt(),
  ingestIntervalSec: (json['ingest_interval_sec'] as num).toInt(),
  tempMinC: (json['temp_min_c'] as num).toDouble(),
  tempMaxC: (json['temp_max_c'] as num).toDouble(),
  tempHysteresisC: (json['temp_hysteresis_c'] as num).toDouble(),
  nh3MaturePpm: (json['nh3_mature_ppm'] as num).toDouble(),
  matureHoldMin: (json['mature_hold_min'] as num).toInt(),
  heaterAuto: json['heater_auto'] as bool,
  heaterMaxOnMin: (json['heater_max_on_min'] as num).toInt(),
  valveMaxOpenMin: (json['valve_max_open_min'] as num).toInt(),
  commandTtlSec: (json['command_ttl_sec'] as num).toInt(),
  rawRetentionDays: (json['raw_retention_days'] as num).toInt(),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$AppSettingsToJson(_AppSettings instance) =>
    <String, dynamic>{
      'id': instance.id,
      'device_id': instance.deviceId,
      'history_interval_min': instance.historyIntervalMin,
      'ingest_interval_sec': instance.ingestIntervalSec,
      'temp_min_c': instance.tempMinC,
      'temp_max_c': instance.tempMaxC,
      'temp_hysteresis_c': instance.tempHysteresisC,
      'nh3_mature_ppm': instance.nh3MaturePpm,
      'mature_hold_min': instance.matureHoldMin,
      'heater_auto': instance.heaterAuto,
      'heater_max_on_min': instance.heaterMaxOnMin,
      'valve_max_open_min': instance.valveMaxOpenMin,
      'command_ttl_sec': instance.commandTtlSec,
      'raw_retention_days': instance.rawRetentionDays,
      'updated_at': instance.updatedAt.toIso8601String(),
    };
