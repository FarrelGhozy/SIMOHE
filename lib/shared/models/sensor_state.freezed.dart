// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sensor_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SensorState {

@JsonKey(name: 'temp_c') double? get tempC;@JsonKey(name: 'nh3_ppm') double? get nh3Ppm;@JsonKey(name: 'temp_ok') bool get tempOk;@JsonKey(name: 'heater_on') bool get heaterOn;@JsonKey(name: 'valve_open') bool get valveOpen; HeaterMode get mode; DeviceStatus get status;@JsonKey(name: 'updated_at') DateTime? get updatedAt;
/// Create a copy of SensorState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SensorStateCopyWith<SensorState> get copyWith => _$SensorStateCopyWithImpl<SensorState>(this as SensorState, _$identity);

  /// Serializes this SensorState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SensorState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SensorState&&(identical(other.tempC, _this.tempC) || other.tempC == _this.tempC)&&(identical(other.nh3Ppm, _this.nh3Ppm) || other.nh3Ppm == _this.nh3Ppm)&&(identical(other.tempOk, _this.tempOk) || other.tempOk == _this.tempOk)&&(identical(other.heaterOn, _this.heaterOn) || other.heaterOn == _this.heaterOn)&&(identical(other.valveOpen, _this.valveOpen) || other.valveOpen == _this.valveOpen)&&(identical(other.mode, _this.mode) || other.mode == _this.mode)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SensorState;
  return Object.hash(runtimeType,_this.tempC,_this.nh3Ppm,_this.tempOk,_this.heaterOn,_this.valveOpen,_this.mode,_this.status,_this.updatedAt);
}

@override
String toString() {
  final _this = this as SensorState;
  return 'SensorState(tempC: ${_this.tempC}, nh3Ppm: ${_this.nh3Ppm}, tempOk: ${_this.tempOk}, heaterOn: ${_this.heaterOn}, valveOpen: ${_this.valveOpen}, mode: ${_this.mode}, status: ${_this.status}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $SensorStateCopyWith<$Res>  {
  factory $SensorStateCopyWith(SensorState value, $Res Function(SensorState) _then) = _$SensorStateCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'temp_c') double? tempC,@JsonKey(name: 'nh3_ppm') double? nh3Ppm,@JsonKey(name: 'temp_ok') bool tempOk,@JsonKey(name: 'heater_on') bool heaterOn,@JsonKey(name: 'valve_open') bool valveOpen, HeaterMode mode, DeviceStatus status,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class _$SensorStateCopyWithImpl<$Res>
    implements $SensorStateCopyWith<$Res> {
  _$SensorStateCopyWithImpl(this._self, this._then);

  final SensorState _self;
  final $Res Function(SensorState) _then;

/// Create a copy of SensorState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tempC = freezed,Object? nh3Ppm = freezed,Object? tempOk = null,Object? heaterOn = null,Object? valveOpen = null,Object? mode = null,Object? status = null,Object? updatedAt = freezed,}) {
  return _then(SensorState(
tempC: freezed == tempC ? _self.tempC : tempC // ignore: cast_nullable_to_non_nullable
as double?,nh3Ppm: freezed == nh3Ppm ? _self.nh3Ppm : nh3Ppm // ignore: cast_nullable_to_non_nullable
as double?,tempOk: null == tempOk ? _self.tempOk : tempOk // ignore: cast_nullable_to_non_nullable
as bool,heaterOn: null == heaterOn ? _self.heaterOn : heaterOn // ignore: cast_nullable_to_non_nullable
as bool,valveOpen: null == valveOpen ? _self.valveOpen : valveOpen // ignore: cast_nullable_to_non_nullable
as bool,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as HeaterMode,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DeviceStatus,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [SensorState].
extension SensorStatePatterns on SensorState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SensorState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SensorState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SensorState value)  $default,){
final _that = this;
switch (_that) {
case _SensorState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SensorState value)?  $default,){
final _that = this;
switch (_that) {
case _SensorState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'temp_c')  double? tempC, @JsonKey(name: 'nh3_ppm')  double? nh3Ppm, @JsonKey(name: 'temp_ok')  bool tempOk, @JsonKey(name: 'heater_on')  bool heaterOn, @JsonKey(name: 'valve_open')  bool valveOpen,  HeaterMode mode,  DeviceStatus status, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SensorState() when $default != null:
return $default(_that.tempC,_that.nh3Ppm,_that.tempOk,_that.heaterOn,_that.valveOpen,_that.mode,_that.status,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'temp_c')  double? tempC, @JsonKey(name: 'nh3_ppm')  double? nh3Ppm, @JsonKey(name: 'temp_ok')  bool tempOk, @JsonKey(name: 'heater_on')  bool heaterOn, @JsonKey(name: 'valve_open')  bool valveOpen,  HeaterMode mode,  DeviceStatus status, @JsonKey(name: 'updated_at')  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _SensorState():
return $default(_that.tempC,_that.nh3Ppm,_that.tempOk,_that.heaterOn,_that.valveOpen,_that.mode,_that.status,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'temp_c')  double? tempC, @JsonKey(name: 'nh3_ppm')  double? nh3Ppm, @JsonKey(name: 'temp_ok')  bool tempOk, @JsonKey(name: 'heater_on')  bool heaterOn, @JsonKey(name: 'valve_open')  bool valveOpen,  HeaterMode mode,  DeviceStatus status, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _SensorState() when $default != null:
return $default(_that.tempC,_that.nh3Ppm,_that.tempOk,_that.heaterOn,_that.valveOpen,_that.mode,_that.status,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SensorState implements SensorState {
  const _SensorState({@JsonKey(name: 'temp_c') this.tempC, @JsonKey(name: 'nh3_ppm') this.nh3Ppm, @JsonKey(name: 'temp_ok') required this.tempOk, @JsonKey(name: 'heater_on') required this.heaterOn, @JsonKey(name: 'valve_open') required this.valveOpen, required this.mode, required this.status, @JsonKey(name: 'updated_at') this.updatedAt});
  factory _SensorState.fromJson(Map<String, dynamic> json) => _$SensorStateFromJson(json);

@override@JsonKey(name: 'temp_c') final  double? tempC;
@override@JsonKey(name: 'nh3_ppm') final  double? nh3Ppm;
@override@JsonKey(name: 'temp_ok') final  bool tempOk;
@override@JsonKey(name: 'heater_on') final  bool heaterOn;
@override@JsonKey(name: 'valve_open') final  bool valveOpen;
@override final  HeaterMode mode;
@override final  DeviceStatus status;
@override@JsonKey(name: 'updated_at') final  DateTime? updatedAt;

/// Create a copy of SensorState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SensorStateCopyWith<_SensorState> get copyWith => __$SensorStateCopyWithImpl<_SensorState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SensorStateToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SensorState&&(identical(other.tempC, tempC) || other.tempC == tempC)&&(identical(other.nh3Ppm, nh3Ppm) || other.nh3Ppm == nh3Ppm)&&(identical(other.tempOk, tempOk) || other.tempOk == tempOk)&&(identical(other.heaterOn, heaterOn) || other.heaterOn == heaterOn)&&(identical(other.valveOpen, valveOpen) || other.valveOpen == valveOpen)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.status, status) || other.status == status)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,tempC,nh3Ppm,tempOk,heaterOn,valveOpen,mode,status,updatedAt);
}

@override
String toString() {
    return 'SensorState(tempC: $tempC, nh3Ppm: $nh3Ppm, tempOk: $tempOk, heaterOn: $heaterOn, valveOpen: $valveOpen, mode: $mode, status: $status, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$SensorStateCopyWith<$Res> implements $SensorStateCopyWith<$Res> {
  factory _$SensorStateCopyWith(_SensorState value, $Res Function(_SensorState) _then) = __$SensorStateCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'temp_c') double? tempC,@JsonKey(name: 'nh3_ppm') double? nh3Ppm,@JsonKey(name: 'temp_ok') bool tempOk,@JsonKey(name: 'heater_on') bool heaterOn,@JsonKey(name: 'valve_open') bool valveOpen, HeaterMode mode, DeviceStatus status,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class __$SensorStateCopyWithImpl<$Res>
    implements _$SensorStateCopyWith<$Res> {
  __$SensorStateCopyWithImpl(this._self, this._then);

  final _SensorState _self;
  final $Res Function(_SensorState) _then;

/// Create a copy of SensorState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tempC = freezed,Object? nh3Ppm = freezed,Object? tempOk = null,Object? heaterOn = null,Object? valveOpen = null,Object? mode = null,Object? status = null,Object? updatedAt = freezed,}) {
  return _then(_SensorState(
tempC: freezed == tempC ? _self.tempC : tempC // ignore: cast_nullable_to_non_nullable
as double?,nh3Ppm: freezed == nh3Ppm ? _self.nh3Ppm : nh3Ppm // ignore: cast_nullable_to_non_nullable
as double?,tempOk: null == tempOk ? _self.tempOk : tempOk // ignore: cast_nullable_to_non_nullable
as bool,heaterOn: null == heaterOn ? _self.heaterOn : heaterOn // ignore: cast_nullable_to_non_nullable
as bool,valveOpen: null == valveOpen ? _self.valveOpen : valveOpen // ignore: cast_nullable_to_non_nullable
as bool,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as HeaterMode,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DeviceStatus,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
