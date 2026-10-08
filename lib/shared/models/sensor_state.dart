import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';

part 'sensor_state.freezed.dart';
part 'sensor_state.g.dart';

@freezed
abstract class SensorState with _$SensorState {
  const factory SensorState({
    @JsonKey(name: 'temp_c') double? tempC,
    @JsonKey(name: 'nh3_ppm') double? nh3Ppm,
    @JsonKey(name: 'temp_ok') required bool tempOk,
    @JsonKey(name: 'heater_on') required bool heaterOn,
    @JsonKey(name: 'valve_open') required bool valveOpen,
    required HeaterMode mode,
    required DeviceStatus status,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _SensorState;

  factory SensorState.fromJson(Map<String, dynamic> json) =>
      _$SensorStateFromJson(json);
}
