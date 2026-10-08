// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'maturity_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MaturityInfo _$MaturityInfoFromJson(Map<String, dynamic> json) =>
    _MaturityInfo(
      mature: json['mature'] as bool,
      progress: (json['progress'] as num).toDouble(),
      thresholdPpm: (json['threshold_ppm'] as num).toDouble(),
      holdMinutes: (json['hold_minutes'] as num).toInt(),
      streakSec: (json['streak_sec'] as num).toInt(),
    );

Map<String, dynamic> _$MaturityInfoToJson(_MaturityInfo instance) =>
    <String, dynamic>{
      'mature': instance.mature,
      'progress': instance.progress,
      'threshold_ppm': instance.thresholdPpm,
      'hold_minutes': instance.holdMinutes,
      'streak_sec': instance.streakSec,
    };
