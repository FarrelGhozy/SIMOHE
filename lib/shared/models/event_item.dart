import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';

part 'event_item.freezed.dart';
part 'event_item.g.dart';

@freezed
abstract class EventItem with _$EventItem {
  const factory EventItem({
    required int id,
    required EventType type,
    required EventSeverity severity,
    required String message,
    @Default(<String, dynamic>{}) Map<String, dynamic> payload,
    @JsonKey(name: 'is_read') required bool isRead,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _EventItem;

  factory EventItem.fromJson(Map<String, dynamic> json) =>
      _$EventItemFromJson(json);
}

@freezed
abstract class EventsResponse with _$EventsResponse {
  const factory EventsResponse({
    @Default(<EventItem>[]) List<EventItem> items,
    @JsonKey(name: 'unread_count') @Default(0) int unreadCount,
  }) = _EventsResponse;

  factory EventsResponse.fromJson(Map<String, dynamic> json) =>
      _$EventsResponseFromJson(json);
}
