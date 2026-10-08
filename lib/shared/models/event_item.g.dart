// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EventItem _$EventItemFromJson(Map<String, dynamic> json) => _EventItem(
  id: (json['id'] as num).toInt(),
  type: $enumDecode(_$EventTypeEnumMap, json['type']),
  severity: $enumDecode(_$EventSeverityEnumMap, json['severity']),
  message: json['message'] as String,
  payload:
      json['payload'] as Map<String, dynamic>? ?? const <String, dynamic>{},
  isRead: json['is_read'] as bool,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$EventItemToJson(_EventItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$EventTypeEnumMap[instance.type]!,
      'severity': _$EventSeverityEnumMap[instance.severity]!,
      'message': instance.message,
      'payload': instance.payload,
      'is_read': instance.isRead,
      'created_at': instance.createdAt?.toIso8601String(),
    };

const _$EventTypeEnumMap = {
  EventType.mature: 'mature',
  EventType.tempLow: 'temp_low',
  EventType.tempHigh: 'temp_high',
  EventType.heaterOn: 'heater_on',
  EventType.heaterOff: 'heater_off',
  EventType.valveOpen: 'valve_open',
  EventType.valveClose: 'valve_close',
  EventType.deviceOffline: 'device_offline',
  EventType.deviceOnline: 'device_online',
  EventType.safetyCutoff: 'safety_cutoff',
};

const _$EventSeverityEnumMap = {
  EventSeverity.info: 'info',
  EventSeverity.warning: 'warning',
  EventSeverity.critical: 'critical',
};

_EventsResponse _$EventsResponseFromJson(Map<String, dynamic> json) =>
    _EventsResponse(
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => EventItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <EventItem>[],
      unreadCount: (json['unread_count'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$EventsResponseToJson(_EventsResponse instance) =>
    <String, dynamic>{
      'items': instance.items,
      'unread_count': instance.unreadCount,
    };
