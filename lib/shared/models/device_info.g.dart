// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DeviceInfo _$DeviceInfoFromJson(Map<String, dynamic> json) => _DeviceInfo(
  id: json['id'] as String,
  name: json['name'] as String,
  location: json['location'] as String?,
  online: json['online'] as bool,
  lastSeenAt: json['last_seen_at'] == null
      ? null
      : DateTime.parse(json['last_seen_at'] as String),
  firmware: json['firmware'] as String?,
);

Map<String, dynamic> _$DeviceInfoToJson(_DeviceInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'location': instance.location,
      'online': instance.online,
      'last_seen_at': instance.lastSeenAt?.toIso8601String(),
      'firmware': instance.firmware,
    };
