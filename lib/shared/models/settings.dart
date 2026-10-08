import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings.freezed.dart';
part 'settings.g.dart';

@freezed
abstract class AppSettings with _$AppSettings {
  const factory AppSettings({
    required int id,
    @JsonKey(name: 'device_id') required int deviceId,
    @JsonKey(name: 'history_interval_min') required int historyIntervalMin,
    @JsonKey(name: 'ingest_interval_sec') required int ingestIntervalSec,
    @JsonKey(name: 'temp_min_c') required double tempMinC,
    @JsonKey(name: 'temp_max_c') required double tempMaxC,
    @JsonKey(name: 'temp_hysteresis_c') required double tempHysteresisC,
    @JsonKey(name: 'nh3_mature_ppm') required double nh3MaturePpm,
    @JsonKey(name: 'mature_hold_min') required int matureHoldMin,
    @JsonKey(name: 'heater_auto') required bool heaterAuto,
    @JsonKey(name: 'heater_max_on_min') required int heaterMaxOnMin,
    @JsonKey(name: 'valve_max_open_min') required int valveMaxOpenMin,
    @JsonKey(name: 'command_ttl_sec') required int commandTtlSec,
    @JsonKey(name: 'raw_retention_days') required int rawRetentionDays,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _AppSettings;

  factory AppSettings.fromJson(Map<String, dynamic> json) =>
      _$AppSettingsFromJson(json);
}

/// Patch parsial untuk `PUT /api/settings`. Field null tidak dikirim.
class SettingsPatch {
  const SettingsPatch({
    this.historyIntervalMin,
    this.ingestIntervalSec,
    this.tempMinC,
    this.tempMaxC,
    this.tempHysteresisC,
    this.nh3MaturePpm,
    this.matureHoldMin,
    this.heaterAuto,
    this.heaterMaxOnMin,
    this.valveMaxOpenMin,
    this.commandTtlSec,
    this.rawRetentionDays,
  });

  final int? historyIntervalMin;
  final int? ingestIntervalSec;
  final double? tempMinC;
  final double? tempMaxC;
  final double? tempHysteresisC;
  final double? nh3MaturePpm;
  final int? matureHoldMin;
  final bool? heaterAuto;
  final int? heaterMaxOnMin;
  final int? valveMaxOpenMin;
  final int? commandTtlSec;
  final int? rawRetentionDays;

  bool get isEmpty => toJson().isEmpty;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    void put(String key, Object? value) {
      if (value != null) json[key] = value;
    }

    put('history_interval_min', historyIntervalMin);
    put('ingest_interval_sec', ingestIntervalSec);
    put('temp_min_c', tempMinC);
    put('temp_max_c', tempMaxC);
    put('temp_hysteresis_c', tempHysteresisC);
    put('nh3_mature_ppm', nh3MaturePpm);
    put('mature_hold_min', matureHoldMin);
    put('heater_auto', heaterAuto);
    put('heater_max_on_min', heaterMaxOnMin);
    put('valve_max_open_min', valveMaxOpenMin);
    put('command_ttl_sec', commandTtlSec);
    put('raw_retention_days', rawRetentionDays);
    return json;
  }
}
