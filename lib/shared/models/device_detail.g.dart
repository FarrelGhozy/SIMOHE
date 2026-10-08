// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DeviceDetail _$DeviceDetailFromJson(Map<String, dynamic> json) =>
    _DeviceDetail(
      id: json['id'] as String,
      name: json['name'] as String,
      location: json['location'] as String?,
      firmware: json['firmware'] as String?,
      isOnline: json['is_online'] as bool,
      lastSeenAt: json['last_seen_at'] == null
          ? null
          : DateTime.parse(json['last_seen_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$DeviceDetailToJson(_DeviceDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'location': instance.location,
      'firmware': instance.firmware,
      'is_online': instance.isOnline,
      'last_seen_at': instance.lastSeenAt?.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
    };
