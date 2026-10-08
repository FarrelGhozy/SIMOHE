import 'package:freezed_annotation/freezed_annotation.dart';

part 'device_info.freezed.dart';
part 'device_info.g.dart';

@freezed
abstract class DeviceInfo with _$DeviceInfo {
  const factory DeviceInfo({
    required String id,
    required String name,
    String? location,
    required bool online,
    @JsonKey(name: 'last_seen_at') DateTime? lastSeenAt,
    String? firmware,
  }) = _DeviceInfo;

  factory DeviceInfo.fromJson(Map<String, dynamic> json) =>
      _$DeviceInfoFromJson(json);
}
