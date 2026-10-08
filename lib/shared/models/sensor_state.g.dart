// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sensor_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SensorState _$SensorStateFromJson(Map<String, dynamic> json) => _SensorState(
  tempC: (json['temp_c'] as num?)?.toDouble(),
  nh3Ppm: (json['nh3_ppm'] as num?)?.toDouble(),
  tempOk: json['temp_ok'] as bool,
  heaterOn: json['heater_on'] as bool,
  valveOpen: json['valve_open'] as bool,
  mode: $enumDecode(_$HeaterModeEnumMap, json['mode']),
  status: $enumDecode(_$DeviceStatusEnumMap, json['status']),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$SensorStateToJson(_SensorState instance) =>
    <String, dynamic>{
      'temp_c': instance.tempC,
      'nh3_ppm': instance.nh3Ppm,
      'temp_ok': instance.tempOk,
      'heater_on': instance.heaterOn,
      'valve_open': instance.valveOpen,
      'mode': _$HeaterModeEnumMap[instance.mode]!,
      'status': _$DeviceStatusEnumMap[instance.status]!,
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

const _$HeaterModeEnumMap = {
  HeaterMode.auto: 'AUTO',
  HeaterMode.forceOn: 'FORCE_ON',
  HeaterMode.forceOff: 'FORCE_OFF',
};

const _$DeviceStatusEnumMap = {
  DeviceStatus.idle: 'idle',
  DeviceStatus.heating: 'heating',
  DeviceStatus.mature: 'mature',
  DeviceStatus.draining: 'draining',
  DeviceStatus.error: 'error',
};
