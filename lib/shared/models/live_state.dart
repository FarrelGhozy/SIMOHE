import 'package:freezed_annotation/freezed_annotation.dart';

import 'device_info.dart';
import 'maturity_info.dart';
import 'sensor_state.dart';

part 'live_state.freezed.dart';
part 'live_state.g.dart';

@freezed
abstract class LiveState with _$LiveState {
  const factory LiveState({
    required DeviceInfo device,
    required SensorState state,
    required MaturityInfo maturity,
  }) = _LiveState;

  factory LiveState.fromJson(Map<String, dynamic> json) =>
      _$LiveStateFromJson(json);
}
