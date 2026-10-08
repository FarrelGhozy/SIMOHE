// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LiveState _$LiveStateFromJson(Map<String, dynamic> json) => _LiveState(
  device: DeviceInfo.fromJson(json['device'] as Map<String, dynamic>),
  state: SensorState.fromJson(json['state'] as Map<String, dynamic>),
  maturity: MaturityInfo.fromJson(json['maturity'] as Map<String, dynamic>),
);

Map<String, dynamic> _$LiveStateToJson(_LiveState instance) =>
    <String, dynamic>{
      'device': instance.device,
      'state': instance.state,
      'maturity': instance.maturity,
    };
