// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'command.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Command _$CommandFromJson(Map<String, dynamic> json) => _Command(
  id: json['id'] as String,
  action: $enumDecode(_$CommandActionEnumMap, json['action']),
  status: $enumDecode(_$CommandStatusEnumMap, json['status']),
  args: json['args'] as Map<String, dynamic>? ?? const <String, dynamic>{},
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  sentAt: json['sent_at'] == null
      ? null
      : DateTime.parse(json['sent_at'] as String),
  ackedAt: json['acked_at'] == null
      ? null
      : DateTime.parse(json['acked_at'] as String),
  expiresAt: json['expires_at'] == null
      ? null
      : DateTime.parse(json['expires_at'] as String),
);

Map<String, dynamic> _$CommandToJson(_Command instance) => <String, dynamic>{
  'id': instance.id,
  'action': _$CommandActionEnumMap[instance.action]!,
  'status': _$CommandStatusEnumMap[instance.status]!,
  'args': instance.args,
  'created_at': instance.createdAt?.toIso8601String(),
  'sent_at': instance.sentAt?.toIso8601String(),
  'acked_at': instance.ackedAt?.toIso8601String(),
  'expires_at': instance.expiresAt?.toIso8601String(),
};

const _$CommandActionEnumMap = {
  CommandAction.valveOpen: 'valve_open',
  CommandAction.valveClose: 'valve_close',
  CommandAction.heaterOn: 'heater_on',
  CommandAction.heaterOff: 'heater_off',
  CommandAction.heaterAuto: 'heater_auto',
};

const _$CommandStatusEnumMap = {
  CommandStatus.pending: 'pending',
  CommandStatus.sent: 'sent',
  CommandStatus.acked: 'acked',
  CommandStatus.failed: 'failed',
  CommandStatus.expired: 'expired',
};

_CreateCommandResult _$CreateCommandResultFromJson(Map<String, dynamic> json) =>
    _CreateCommandResult(
      id: json['id'] as String,
      action: $enumDecode(_$CommandActionEnumMap, json['action']),
      status: $enumDecode(_$CommandStatusEnumMap, json['status']),
      expiresAt: DateTime.parse(json['expires_at'] as String),
    );

Map<String, dynamic> _$CreateCommandResultToJson(
  _CreateCommandResult instance,
) => <String, dynamic>{
  'id': instance.id,
  'action': _$CommandActionEnumMap[instance.action]!,
  'status': _$CommandStatusEnumMap[instance.status]!,
  'expires_at': instance.expiresAt.toIso8601String(),
};
