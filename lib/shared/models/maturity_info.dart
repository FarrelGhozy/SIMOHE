import 'package:freezed_annotation/freezed_annotation.dart';

part 'maturity_info.freezed.dart';
part 'maturity_info.g.dart';

@freezed
abstract class MaturityInfo with _$MaturityInfo {
  const factory MaturityInfo({
    required bool mature,
    required double progress,
    @JsonKey(name: 'threshold_ppm') required double thresholdPpm,
    @JsonKey(name: 'hold_minutes') required int holdMinutes,
    @JsonKey(name: 'streak_sec') required int streakSec,
  }) = _MaturityInfo;

  factory MaturityInfo.fromJson(Map<String, dynamic> json) =>
      _$MaturityInfoFromJson(json);
}
