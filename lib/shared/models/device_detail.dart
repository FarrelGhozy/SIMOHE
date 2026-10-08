import 'package:freezed_annotation/freezed_annotation.dart';

part 'device_detail.freezed.dart';
part 'device_detail.g.dart';

@freezed
abstract class DeviceDetail with _$DeviceDetail {
  const factory DeviceDetail({
    required String id,
    required String name,
    String? location,
    String? firmware,
    @JsonKey(name: 'is_online') required bool isOnline,
    @JsonKey(name: 'last_seen_at') DateTime? lastSeenAt,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _DeviceDetail;

  factory DeviceDetail.fromJson(Map<String, dynamic> json) =>
      _$DeviceDetailFromJson(json);
}
