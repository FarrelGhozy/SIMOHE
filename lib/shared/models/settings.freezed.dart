// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppSettings {

 int get id;@JsonKey(name: 'device_id') int get deviceId;@JsonKey(name: 'history_interval_min') int get historyIntervalMin;@JsonKey(name: 'ingest_interval_sec') int get ingestIntervalSec;@JsonKey(name: 'temp_min_c') double get tempMinC;@JsonKey(name: 'temp_max_c') double get tempMaxC;@JsonKey(name: 'temp_hysteresis_c') double get tempHysteresisC;@JsonKey(name: 'nh3_mature_ppm') double get nh3MaturePpm;@JsonKey(name: 'mature_hold_min') int get matureHoldMin;@JsonKey(name: 'heater_auto') bool get heaterAuto;@JsonKey(name: 'heater_max_on_min') int get heaterMaxOnMin;@JsonKey(name: 'valve_max_open_min') int get valveMaxOpenMin;@JsonKey(name: 'command_ttl_sec') int get commandTtlSec;@JsonKey(name: 'raw_retention_days') int get rawRetentionDays;@JsonKey(name: 'updated_at') DateTime get updatedAt;
/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppSettingsCopyWith<AppSettings> get copyWith => _$AppSettingsCopyWithImpl<AppSettings>(this as AppSettings, _$identity);

  /// Serializes this AppSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AppSettings;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppSettings&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.deviceId, _this.deviceId) || other.deviceId == _this.deviceId)&&(identical(other.historyIntervalMin, _this.historyIntervalMin) || other.historyIntervalMin == _this.historyIntervalMin)&&(identical(other.ingestIntervalSec, _this.ingestIntervalSec) || other.ingestIntervalSec == _this.ingestIntervalSec)&&(identical(other.tempMinC, _this.tempMinC) || other.tempMinC == _this.tempMinC)&&(identical(other.tempMaxC, _this.tempMaxC) || other.tempMaxC == _this.tempMaxC)&&(identical(other.tempHysteresisC, _this.tempHysteresisC) || other.tempHysteresisC == _this.tempHysteresisC)&&(identical(other.nh3MaturePpm, _this.nh3MaturePpm) || other.nh3MaturePpm == _this.nh3MaturePpm)&&(identical(other.matureHoldMin, _this.matureHoldMin) || other.matureHoldMin == _this.matureHoldMin)&&(identical(other.heaterAuto, _this.heaterAuto) || other.heaterAuto == _this.heaterAuto)&&(identical(other.heaterMaxOnMin, _this.heaterMaxOnMin) || other.heaterMaxOnMin == _this.heaterMaxOnMin)&&(identical(other.valveMaxOpenMin, _this.valveMaxOpenMin) || other.valveMaxOpenMin == _this.valveMaxOpenMin)&&(identical(other.commandTtlSec, _this.commandTtlSec) || other.commandTtlSec == _this.commandTtlSec)&&(identical(other.rawRetentionDays, _this.rawRetentionDays) || other.rawRetentionDays == _this.rawRetentionDays)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AppSettings;
  return Object.hash(runtimeType,_this.id,_this.deviceId,_this.historyIntervalMin,_this.ingestIntervalSec,_this.tempMinC,_this.tempMaxC,_this.tempHysteresisC,_this.nh3MaturePpm,_this.matureHoldMin,_this.heaterAuto,_this.heaterMaxOnMin,_this.valveMaxOpenMin,_this.commandTtlSec,_this.rawRetentionDays,_this.updatedAt);
}

@override
String toString() {
  final _this = this as AppSettings;
  return 'AppSettings(id: ${_this.id}, deviceId: ${_this.deviceId}, historyIntervalMin: ${_this.historyIntervalMin}, ingestIntervalSec: ${_this.ingestIntervalSec}, tempMinC: ${_this.tempMinC}, tempMaxC: ${_this.tempMaxC}, tempHysteresisC: ${_this.tempHysteresisC}, nh3MaturePpm: ${_this.nh3MaturePpm}, matureHoldMin: ${_this.matureHoldMin}, heaterAuto: ${_this.heaterAuto}, heaterMaxOnMin: ${_this.heaterMaxOnMin}, valveMaxOpenMin: ${_this.valveMaxOpenMin}, commandTtlSec: ${_this.commandTtlSec}, rawRetentionDays: ${_this.rawRetentionDays}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $AppSettingsCopyWith<$Res>  {
  factory $AppSettingsCopyWith(AppSettings value, $Res Function(AppSettings) _then) = _$AppSettingsCopyWithImpl;
@useResult
$Res call({
 int id,@JsonKey(name: 'device_id') int deviceId,@JsonKey(name: 'history_interval_min') int historyIntervalMin,@JsonKey(name: 'ingest_interval_sec') int ingestIntervalSec,@JsonKey(name: 'temp_min_c') double tempMinC,@JsonKey(name: 'temp_max_c') double tempMaxC,@JsonKey(name: 'temp_hysteresis_c') double tempHysteresisC,@JsonKey(name: 'nh3_mature_ppm') double nh3MaturePpm,@JsonKey(name: 'mature_hold_min') int matureHoldMin,@JsonKey(name: 'heater_auto') bool heaterAuto,@JsonKey(name: 'heater_max_on_min') int heaterMaxOnMin,@JsonKey(name: 'valve_max_open_min') int valveMaxOpenMin,@JsonKey(name: 'command_ttl_sec') int commandTtlSec,@JsonKey(name: 'raw_retention_days') int rawRetentionDays,@JsonKey(name: 'updated_at') DateTime updatedAt
});




}
/// @nodoc
class _$AppSettingsCopyWithImpl<$Res>
    implements $AppSettingsCopyWith<$Res> {
  _$AppSettingsCopyWithImpl(this._self, this._then);

  final AppSettings _self;
  final $Res Function(AppSettings) _then;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? deviceId = null,Object? historyIntervalMin = null,Object? ingestIntervalSec = null,Object? tempMinC = null,Object? tempMaxC = null,Object? tempHysteresisC = null,Object? nh3MaturePpm = null,Object? matureHoldMin = null,Object? heaterAuto = null,Object? heaterMaxOnMin = null,Object? valveMaxOpenMin = null,Object? commandTtlSec = null,Object? rawRetentionDays = null,Object? updatedAt = null,}) {
  return _then(AppSettings(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,deviceId: null == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as int,historyIntervalMin: null == historyIntervalMin ? _self.historyIntervalMin : historyIntervalMin // ignore: cast_nullable_to_non_nullable
as int,ingestIntervalSec: null == ingestIntervalSec ? _self.ingestIntervalSec : ingestIntervalSec // ignore: cast_nullable_to_non_nullable
as int,tempMinC: null == tempMinC ? _self.tempMinC : tempMinC // ignore: cast_nullable_to_non_nullable
as double,tempMaxC: null == tempMaxC ? _self.tempMaxC : tempMaxC // ignore: cast_nullable_to_non_nullable
as double,tempHysteresisC: null == tempHysteresisC ? _self.tempHysteresisC : tempHysteresisC // ignore: cast_nullable_to_non_nullable
as double,nh3MaturePpm: null == nh3MaturePpm ? _self.nh3MaturePpm : nh3MaturePpm // ignore: cast_nullable_to_non_nullable
as double,matureHoldMin: null == matureHoldMin ? _self.matureHoldMin : matureHoldMin // ignore: cast_nullable_to_non_nullable
as int,heaterAuto: null == heaterAuto ? _self.heaterAuto : heaterAuto // ignore: cast_nullable_to_non_nullable
as bool,heaterMaxOnMin: null == heaterMaxOnMin ? _self.heaterMaxOnMin : heaterMaxOnMin // ignore: cast_nullable_to_non_nullable
as int,valveMaxOpenMin: null == valveMaxOpenMin ? _self.valveMaxOpenMin : valveMaxOpenMin // ignore: cast_nullable_to_non_nullable
as int,commandTtlSec: null == commandTtlSec ? _self.commandTtlSec : commandTtlSec // ignore: cast_nullable_to_non_nullable
as int,rawRetentionDays: null == rawRetentionDays ? _self.rawRetentionDays : rawRetentionDays // ignore: cast_nullable_to_non_nullable
as int,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [AppSettings].
extension AppSettingsPatterns on AppSettings {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppSettings value)  $default,){
final _that = this;
switch (_that) {
case _AppSettings():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppSettings value)?  $default,){
final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id, @JsonKey(name: 'device_id')  int deviceId, @JsonKey(name: 'history_interval_min')  int historyIntervalMin, @JsonKey(name: 'ingest_interval_sec')  int ingestIntervalSec, @JsonKey(name: 'temp_min_c')  double tempMinC, @JsonKey(name: 'temp_max_c')  double tempMaxC, @JsonKey(name: 'temp_hysteresis_c')  double tempHysteresisC, @JsonKey(name: 'nh3_mature_ppm')  double nh3MaturePpm, @JsonKey(name: 'mature_hold_min')  int matureHoldMin, @JsonKey(name: 'heater_auto')  bool heaterAuto, @JsonKey(name: 'heater_max_on_min')  int heaterMaxOnMin, @JsonKey(name: 'valve_max_open_min')  int valveMaxOpenMin, @JsonKey(name: 'command_ttl_sec')  int commandTtlSec, @JsonKey(name: 'raw_retention_days')  int rawRetentionDays, @JsonKey(name: 'updated_at')  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
return $default(_that.id,_that.deviceId,_that.historyIntervalMin,_that.ingestIntervalSec,_that.tempMinC,_that.tempMaxC,_that.tempHysteresisC,_that.nh3MaturePpm,_that.matureHoldMin,_that.heaterAuto,_that.heaterMaxOnMin,_that.valveMaxOpenMin,_that.commandTtlSec,_that.rawRetentionDays,_that.updatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id, @JsonKey(name: 'device_id')  int deviceId, @JsonKey(name: 'history_interval_min')  int historyIntervalMin, @JsonKey(name: 'ingest_interval_sec')  int ingestIntervalSec, @JsonKey(name: 'temp_min_c')  double tempMinC, @JsonKey(name: 'temp_max_c')  double tempMaxC, @JsonKey(name: 'temp_hysteresis_c')  double tempHysteresisC, @JsonKey(name: 'nh3_mature_ppm')  double nh3MaturePpm, @JsonKey(name: 'mature_hold_min')  int matureHoldMin, @JsonKey(name: 'heater_auto')  bool heaterAuto, @JsonKey(name: 'heater_max_on_min')  int heaterMaxOnMin, @JsonKey(name: 'valve_max_open_min')  int valveMaxOpenMin, @JsonKey(name: 'command_ttl_sec')  int commandTtlSec, @JsonKey(name: 'raw_retention_days')  int rawRetentionDays, @JsonKey(name: 'updated_at')  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _AppSettings():
return $default(_that.id,_that.deviceId,_that.historyIntervalMin,_that.ingestIntervalSec,_that.tempMinC,_that.tempMaxC,_that.tempHysteresisC,_that.nh3MaturePpm,_that.matureHoldMin,_that.heaterAuto,_that.heaterMaxOnMin,_that.valveMaxOpenMin,_that.commandTtlSec,_that.rawRetentionDays,_that.updatedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id, @JsonKey(name: 'device_id')  int deviceId, @JsonKey(name: 'history_interval_min')  int historyIntervalMin, @JsonKey(name: 'ingest_interval_sec')  int ingestIntervalSec, @JsonKey(name: 'temp_min_c')  double tempMinC, @JsonKey(name: 'temp_max_c')  double tempMaxC, @JsonKey(name: 'temp_hysteresis_c')  double tempHysteresisC, @JsonKey(name: 'nh3_mature_ppm')  double nh3MaturePpm, @JsonKey(name: 'mature_hold_min')  int matureHoldMin, @JsonKey(name: 'heater_auto')  bool heaterAuto, @JsonKey(name: 'heater_max_on_min')  int heaterMaxOnMin, @JsonKey(name: 'valve_max_open_min')  int valveMaxOpenMin, @JsonKey(name: 'command_ttl_sec')  int commandTtlSec, @JsonKey(name: 'raw_retention_days')  int rawRetentionDays, @JsonKey(name: 'updated_at')  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
return $default(_that.id,_that.deviceId,_that.historyIntervalMin,_that.ingestIntervalSec,_that.tempMinC,_that.tempMaxC,_that.tempHysteresisC,_that.nh3MaturePpm,_that.matureHoldMin,_that.heaterAuto,_that.heaterMaxOnMin,_that.valveMaxOpenMin,_that.commandTtlSec,_that.rawRetentionDays,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppSettings implements AppSettings {
  const _AppSettings({required this.id, @JsonKey(name: 'device_id') required this.deviceId, @JsonKey(name: 'history_interval_min') required this.historyIntervalMin, @JsonKey(name: 'ingest_interval_sec') required this.ingestIntervalSec, @JsonKey(name: 'temp_min_c') required this.tempMinC, @JsonKey(name: 'temp_max_c') required this.tempMaxC, @JsonKey(name: 'temp_hysteresis_c') required this.tempHysteresisC, @JsonKey(name: 'nh3_mature_ppm') required this.nh3MaturePpm, @JsonKey(name: 'mature_hold_min') required this.matureHoldMin, @JsonKey(name: 'heater_auto') required this.heaterAuto, @JsonKey(name: 'heater_max_on_min') required this.heaterMaxOnMin, @JsonKey(name: 'valve_max_open_min') required this.valveMaxOpenMin, @JsonKey(name: 'command_ttl_sec') required this.commandTtlSec, @JsonKey(name: 'raw_retention_days') required this.rawRetentionDays, @JsonKey(name: 'updated_at') required this.updatedAt});
  factory _AppSettings.fromJson(Map<String, dynamic> json) => _$AppSettingsFromJson(json);

@override final  int id;
@override@JsonKey(name: 'device_id') final  int deviceId;
@override@JsonKey(name: 'history_interval_min') final  int historyIntervalMin;
@override@JsonKey(name: 'ingest_interval_sec') final  int ingestIntervalSec;
@override@JsonKey(name: 'temp_min_c') final  double tempMinC;
@override@JsonKey(name: 'temp_max_c') final  double tempMaxC;
@override@JsonKey(name: 'temp_hysteresis_c') final  double tempHysteresisC;
@override@JsonKey(name: 'nh3_mature_ppm') final  double nh3MaturePpm;
@override@JsonKey(name: 'mature_hold_min') final  int matureHoldMin;
@override@JsonKey(name: 'heater_auto') final  bool heaterAuto;
@override@JsonKey(name: 'heater_max_on_min') final  int heaterMaxOnMin;
@override@JsonKey(name: 'valve_max_open_min') final  int valveMaxOpenMin;
@override@JsonKey(name: 'command_ttl_sec') final  int commandTtlSec;
@override@JsonKey(name: 'raw_retention_days') final  int rawRetentionDays;
@override@JsonKey(name: 'updated_at') final  DateTime updatedAt;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppSettingsCopyWith<_AppSettings> get copyWith => __$AppSettingsCopyWithImpl<_AppSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppSettings&&(identical(other.id, id) || other.id == id)&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId)&&(identical(other.historyIntervalMin, historyIntervalMin) || other.historyIntervalMin == historyIntervalMin)&&(identical(other.ingestIntervalSec, ingestIntervalSec) || other.ingestIntervalSec == ingestIntervalSec)&&(identical(other.tempMinC, tempMinC) || other.tempMinC == tempMinC)&&(identical(other.tempMaxC, tempMaxC) || other.tempMaxC == tempMaxC)&&(identical(other.tempHysteresisC, tempHysteresisC) || other.tempHysteresisC == tempHysteresisC)&&(identical(other.nh3MaturePpm, nh3MaturePpm) || other.nh3MaturePpm == nh3MaturePpm)&&(identical(other.matureHoldMin, matureHoldMin) || other.matureHoldMin == matureHoldMin)&&(identical(other.heaterAuto, heaterAuto) || other.heaterAuto == heaterAuto)&&(identical(other.heaterMaxOnMin, heaterMaxOnMin) || other.heaterMaxOnMin == heaterMaxOnMin)&&(identical(other.valveMaxOpenMin, valveMaxOpenMin) || other.valveMaxOpenMin == valveMaxOpenMin)&&(identical(other.commandTtlSec, commandTtlSec) || other.commandTtlSec == commandTtlSec)&&(identical(other.rawRetentionDays, rawRetentionDays) || other.rawRetentionDays == rawRetentionDays)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,deviceId,historyIntervalMin,ingestIntervalSec,tempMinC,tempMaxC,tempHysteresisC,nh3MaturePpm,matureHoldMin,heaterAuto,heaterMaxOnMin,valveMaxOpenMin,commandTtlSec,rawRetentionDays,updatedAt);
}

@override
String toString() {
    return 'AppSettings(id: $id, deviceId: $deviceId, historyIntervalMin: $historyIntervalMin, ingestIntervalSec: $ingestIntervalSec, tempMinC: $tempMinC, tempMaxC: $tempMaxC, tempHysteresisC: $tempHysteresisC, nh3MaturePpm: $nh3MaturePpm, matureHoldMin: $matureHoldMin, heaterAuto: $heaterAuto, heaterMaxOnMin: $heaterMaxOnMin, valveMaxOpenMin: $valveMaxOpenMin, commandTtlSec: $commandTtlSec, rawRetentionDays: $rawRetentionDays, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$AppSettingsCopyWith<$Res> implements $AppSettingsCopyWith<$Res> {
  factory _$AppSettingsCopyWith(_AppSettings value, $Res Function(_AppSettings) _then) = __$AppSettingsCopyWithImpl;
@override @useResult
$Res call({
 int id,@JsonKey(name: 'device_id') int deviceId,@JsonKey(name: 'history_interval_min') int historyIntervalMin,@JsonKey(name: 'ingest_interval_sec') int ingestIntervalSec,@JsonKey(name: 'temp_min_c') double tempMinC,@JsonKey(name: 'temp_max_c') double tempMaxC,@JsonKey(name: 'temp_hysteresis_c') double tempHysteresisC,@JsonKey(name: 'nh3_mature_ppm') double nh3MaturePpm,@JsonKey(name: 'mature_hold_min') int matureHoldMin,@JsonKey(name: 'heater_auto') bool heaterAuto,@JsonKey(name: 'heater_max_on_min') int heaterMaxOnMin,@JsonKey(name: 'valve_max_open_min') int valveMaxOpenMin,@JsonKey(name: 'command_ttl_sec') int commandTtlSec,@JsonKey(name: 'raw_retention_days') int rawRetentionDays,@JsonKey(name: 'updated_at') DateTime updatedAt
});




}
/// @nodoc
class __$AppSettingsCopyWithImpl<$Res>
    implements _$AppSettingsCopyWith<$Res> {
  __$AppSettingsCopyWithImpl(this._self, this._then);

  final _AppSettings _self;
  final $Res Function(_AppSettings) _then;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? deviceId = null,Object? historyIntervalMin = null,Object? ingestIntervalSec = null,Object? tempMinC = null,Object? tempMaxC = null,Object? tempHysteresisC = null,Object? nh3MaturePpm = null,Object? matureHoldMin = null,Object? heaterAuto = null,Object? heaterMaxOnMin = null,Object? valveMaxOpenMin = null,Object? commandTtlSec = null,Object? rawRetentionDays = null,Object? updatedAt = null,}) {
  return _then(_AppSettings(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,deviceId: null == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as int,historyIntervalMin: null == historyIntervalMin ? _self.historyIntervalMin : historyIntervalMin // ignore: cast_nullable_to_non_nullable
as int,ingestIntervalSec: null == ingestIntervalSec ? _self.ingestIntervalSec : ingestIntervalSec // ignore: cast_nullable_to_non_nullable
as int,tempMinC: null == tempMinC ? _self.tempMinC : tempMinC // ignore: cast_nullable_to_non_nullable
as double,tempMaxC: null == tempMaxC ? _self.tempMaxC : tempMaxC // ignore: cast_nullable_to_non_nullable
as double,tempHysteresisC: null == tempHysteresisC ? _self.tempHysteresisC : tempHysteresisC // ignore: cast_nullable_to_non_nullable
as double,nh3MaturePpm: null == nh3MaturePpm ? _self.nh3MaturePpm : nh3MaturePpm // ignore: cast_nullable_to_non_nullable
as double,matureHoldMin: null == matureHoldMin ? _self.matureHoldMin : matureHoldMin // ignore: cast_nullable_to_non_nullable
as int,heaterAuto: null == heaterAuto ? _self.heaterAuto : heaterAuto // ignore: cast_nullable_to_non_nullable
as bool,heaterMaxOnMin: null == heaterMaxOnMin ? _self.heaterMaxOnMin : heaterMaxOnMin // ignore: cast_nullable_to_non_nullable
as int,valveMaxOpenMin: null == valveMaxOpenMin ? _self.valveMaxOpenMin : valveMaxOpenMin // ignore: cast_nullable_to_non_nullable
as int,commandTtlSec: null == commandTtlSec ? _self.commandTtlSec : commandTtlSec // ignore: cast_nullable_to_non_nullable
as int,rawRetentionDays: null == rawRetentionDays ? _self.rawRetentionDays : rawRetentionDays // ignore: cast_nullable_to_non_nullable
as int,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
