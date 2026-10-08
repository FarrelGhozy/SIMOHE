// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'maturity_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MaturityInfo {

 bool get mature; double get progress;@JsonKey(name: 'threshold_ppm') double get thresholdPpm;@JsonKey(name: 'hold_minutes') int get holdMinutes;@JsonKey(name: 'streak_sec') int get streakSec;
/// Create a copy of MaturityInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MaturityInfoCopyWith<MaturityInfo> get copyWith => _$MaturityInfoCopyWithImpl<MaturityInfo>(this as MaturityInfo, _$identity);

  /// Serializes this MaturityInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as MaturityInfo;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MaturityInfo&&(identical(other.mature, _this.mature) || other.mature == _this.mature)&&(identical(other.progress, _this.progress) || other.progress == _this.progress)&&(identical(other.thresholdPpm, _this.thresholdPpm) || other.thresholdPpm == _this.thresholdPpm)&&(identical(other.holdMinutes, _this.holdMinutes) || other.holdMinutes == _this.holdMinutes)&&(identical(other.streakSec, _this.streakSec) || other.streakSec == _this.streakSec));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MaturityInfo;
  return Object.hash(runtimeType,_this.mature,_this.progress,_this.thresholdPpm,_this.holdMinutes,_this.streakSec);
}

@override
String toString() {
  final _this = this as MaturityInfo;
  return 'MaturityInfo(mature: ${_this.mature}, progress: ${_this.progress}, thresholdPpm: ${_this.thresholdPpm}, holdMinutes: ${_this.holdMinutes}, streakSec: ${_this.streakSec})';
}


}

/// @nodoc
abstract mixin class $MaturityInfoCopyWith<$Res>  {
  factory $MaturityInfoCopyWith(MaturityInfo value, $Res Function(MaturityInfo) _then) = _$MaturityInfoCopyWithImpl;
@useResult
$Res call({
 bool mature, double progress,@JsonKey(name: 'threshold_ppm') double thresholdPpm,@JsonKey(name: 'hold_minutes') int holdMinutes,@JsonKey(name: 'streak_sec') int streakSec
});




}
/// @nodoc
class _$MaturityInfoCopyWithImpl<$Res>
    implements $MaturityInfoCopyWith<$Res> {
  _$MaturityInfoCopyWithImpl(this._self, this._then);

  final MaturityInfo _self;
  final $Res Function(MaturityInfo) _then;

/// Create a copy of MaturityInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mature = null,Object? progress = null,Object? thresholdPpm = null,Object? holdMinutes = null,Object? streakSec = null,}) {
  return _then(MaturityInfo(
mature: null == mature ? _self.mature : mature // ignore: cast_nullable_to_non_nullable
as bool,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,thresholdPpm: null == thresholdPpm ? _self.thresholdPpm : thresholdPpm // ignore: cast_nullable_to_non_nullable
as double,holdMinutes: null == holdMinutes ? _self.holdMinutes : holdMinutes // ignore: cast_nullable_to_non_nullable
as int,streakSec: null == streakSec ? _self.streakSec : streakSec // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [MaturityInfo].
extension MaturityInfoPatterns on MaturityInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MaturityInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MaturityInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MaturityInfo value)  $default,){
final _that = this;
switch (_that) {
case _MaturityInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MaturityInfo value)?  $default,){
final _that = this;
switch (_that) {
case _MaturityInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool mature,  double progress, @JsonKey(name: 'threshold_ppm')  double thresholdPpm, @JsonKey(name: 'hold_minutes')  int holdMinutes, @JsonKey(name: 'streak_sec')  int streakSec)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MaturityInfo() when $default != null:
return $default(_that.mature,_that.progress,_that.thresholdPpm,_that.holdMinutes,_that.streakSec);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool mature,  double progress, @JsonKey(name: 'threshold_ppm')  double thresholdPpm, @JsonKey(name: 'hold_minutes')  int holdMinutes, @JsonKey(name: 'streak_sec')  int streakSec)  $default,) {final _that = this;
switch (_that) {
case _MaturityInfo():
return $default(_that.mature,_that.progress,_that.thresholdPpm,_that.holdMinutes,_that.streakSec);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool mature,  double progress, @JsonKey(name: 'threshold_ppm')  double thresholdPpm, @JsonKey(name: 'hold_minutes')  int holdMinutes, @JsonKey(name: 'streak_sec')  int streakSec)?  $default,) {final _that = this;
switch (_that) {
case _MaturityInfo() when $default != null:
return $default(_that.mature,_that.progress,_that.thresholdPpm,_that.holdMinutes,_that.streakSec);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MaturityInfo implements MaturityInfo {
  const _MaturityInfo({required this.mature, required this.progress, @JsonKey(name: 'threshold_ppm') required this.thresholdPpm, @JsonKey(name: 'hold_minutes') required this.holdMinutes, @JsonKey(name: 'streak_sec') required this.streakSec});
  factory _MaturityInfo.fromJson(Map<String, dynamic> json) => _$MaturityInfoFromJson(json);

@override final  bool mature;
@override final  double progress;
@override@JsonKey(name: 'threshold_ppm') final  double thresholdPpm;
@override@JsonKey(name: 'hold_minutes') final  int holdMinutes;
@override@JsonKey(name: 'streak_sec') final  int streakSec;

/// Create a copy of MaturityInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MaturityInfoCopyWith<_MaturityInfo> get copyWith => __$MaturityInfoCopyWithImpl<_MaturityInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MaturityInfoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MaturityInfo&&(identical(other.mature, mature) || other.mature == mature)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.thresholdPpm, thresholdPpm) || other.thresholdPpm == thresholdPpm)&&(identical(other.holdMinutes, holdMinutes) || other.holdMinutes == holdMinutes)&&(identical(other.streakSec, streakSec) || other.streakSec == streakSec));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,mature,progress,thresholdPpm,holdMinutes,streakSec);
}

@override
String toString() {
    return 'MaturityInfo(mature: $mature, progress: $progress, thresholdPpm: $thresholdPpm, holdMinutes: $holdMinutes, streakSec: $streakSec)';
}


}

/// @nodoc
abstract mixin class _$MaturityInfoCopyWith<$Res> implements $MaturityInfoCopyWith<$Res> {
  factory _$MaturityInfoCopyWith(_MaturityInfo value, $Res Function(_MaturityInfo) _then) = __$MaturityInfoCopyWithImpl;
@override @useResult
$Res call({
 bool mature, double progress,@JsonKey(name: 'threshold_ppm') double thresholdPpm,@JsonKey(name: 'hold_minutes') int holdMinutes,@JsonKey(name: 'streak_sec') int streakSec
});




}
/// @nodoc
class __$MaturityInfoCopyWithImpl<$Res>
    implements _$MaturityInfoCopyWith<$Res> {
  __$MaturityInfoCopyWithImpl(this._self, this._then);

  final _MaturityInfo _self;
  final $Res Function(_MaturityInfo) _then;

/// Create a copy of MaturityInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mature = null,Object? progress = null,Object? thresholdPpm = null,Object? holdMinutes = null,Object? streakSec = null,}) {
  return _then(_MaturityInfo(
mature: null == mature ? _self.mature : mature // ignore: cast_nullable_to_non_nullable
as bool,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,thresholdPpm: null == thresholdPpm ? _self.thresholdPpm : thresholdPpm // ignore: cast_nullable_to_non_nullable
as double,holdMinutes: null == holdMinutes ? _self.holdMinutes : holdMinutes // ignore: cast_nullable_to_non_nullable
as int,streakSec: null == streakSec ? _self.streakSec : streakSec // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
