import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';

part 'reading.freezed.dart';
part 'reading.g.dart';

@freezed
abstract class ReadingPoint with _$ReadingPoint {
  const factory ReadingPoint({
    DateTime? ts,
    @JsonKey(name: 'temp_c') double? tempC,
    @JsonKey(name: 'nh3_ppm') double? nh3Ppm,
    @JsonKey(name: 'heater_on') required bool heaterOn,
    @JsonKey(name: 'valve_open') required bool valveOpen,
  }) = _ReadingPoint;

  factory ReadingPoint.fromJson(Map<String, dynamic> json) =>
      _$ReadingPointFromJson(json);
}

@freezed
abstract class ReadingsResponse with _$ReadingsResponse {
  const factory ReadingsResponse({
    required ReadingBucket bucket,
    DateTime? from,
    DateTime? to,
    @Default(<ReadingPoint>[]) List<ReadingPoint> items,
  }) = _ReadingsResponse;

  factory ReadingsResponse.fromJson(Map<String, dynamic> json) =>
      _$ReadingsResponseFromJson(json);
}
