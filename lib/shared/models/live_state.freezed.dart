// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'live_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LiveState {

 DeviceInfo get device; SensorState get state; MaturityInfo get maturity;
/// Create a copy of LiveState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LiveStateCopyWith<LiveState> get copyWith => _$LiveStateCopyWithImpl<LiveState>(this as LiveState, _$identity);

  /// Serializes this LiveState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as LiveState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LiveState&&(identical(other.device, _this.device) || other.device == _this.device)&&(identical(other.state, _this.state) || other.state == _this.state)&&(identical(other.maturity, _this.maturity) || other.maturity == _this.maturity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as LiveState;
  return Object.hash(runtimeType,_this.device,_this.state,_this.maturity);
}

@override
String toString() {
  final _this = this as LiveState;
  return 'LiveState(device: ${_this.device}, state: ${_this.state}, maturity: ${_this.maturity})';
}


}

/// @nodoc
abstract mixin class $LiveStateCopyWith<$Res>  {
  factory $LiveStateCopyWith(LiveState value, $Res Function(LiveState) _then) = _$LiveStateCopyWithImpl;
@useResult
$Res call({
 DeviceInfo device, SensorState state, MaturityInfo maturity
});


$DeviceInfoCopyWith<$Res> get device;$SensorStateCopyWith<$Res> get state;$MaturityInfoCopyWith<$Res> get maturity;

}
/// @nodoc
class _$LiveStateCopyWithImpl<$Res>
    implements $LiveStateCopyWith<$Res> {
  _$LiveStateCopyWithImpl(this._self, this._then);

  final LiveState _self;
  final $Res Function(LiveState) _then;

/// Create a copy of LiveState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? device = null,Object? state = null,Object? maturity = null,}) {
  return _then(LiveState(
device: null == device ? _self.device : device // ignore: cast_nullable_to_non_nullable
as DeviceInfo,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as SensorState,maturity: null == maturity ? _self.maturity : maturity // ignore: cast_nullable_to_non_nullable
as MaturityInfo,
  ));
}
/// Create a copy of LiveState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DeviceInfoCopyWith<$Res> get device {
  
  return $DeviceInfoCopyWith<$Res>(_self.device, (value) {
    return _then(_self.copyWith(device: value));
  });
}/// Create a copy of LiveState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SensorStateCopyWith<$Res> get state {
  
  return $SensorStateCopyWith<$Res>(_self.state, (value) {
    return _then(_self.copyWith(state: value));
  });
}/// Create a copy of LiveState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MaturityInfoCopyWith<$Res> get maturity {
  
  return $MaturityInfoCopyWith<$Res>(_self.maturity, (value) {
    return _then(_self.copyWith(maturity: value));
  });
}
}


/// Adds pattern-matching-related methods to [LiveState].
extension LiveStatePatterns on LiveState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LiveState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LiveState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LiveState value)  $default,){
final _that = this;
switch (_that) {
case _LiveState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LiveState value)?  $default,){
final _that = this;
switch (_that) {
case _LiveState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DeviceInfo device,  SensorState state,  MaturityInfo maturity)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LiveState() when $default != null:
return $default(_that.device,_that.state,_that.maturity);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DeviceInfo device,  SensorState state,  MaturityInfo maturity)  $default,) {final _that = this;
switch (_that) {
case _LiveState():
return $default(_that.device,_that.state,_that.maturity);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DeviceInfo device,  SensorState state,  MaturityInfo maturity)?  $default,) {final _that = this;
switch (_that) {
case _LiveState() when $default != null:
return $default(_that.device,_that.state,_that.maturity);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LiveState implements LiveState {
  const _LiveState({required this.device, required this.state, required this.maturity});
  factory _LiveState.fromJson(Map<String, dynamic> json) => _$LiveStateFromJson(json);

@override final  DeviceInfo device;
@override final  SensorState state;
@override final  MaturityInfo maturity;

/// Create a copy of LiveState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LiveStateCopyWith<_LiveState> get copyWith => __$LiveStateCopyWithImpl<_LiveState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LiveStateToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LiveState&&(identical(other.device, device) || other.device == device)&&(identical(other.state, state) || other.state == state)&&(identical(other.maturity, maturity) || other.maturity == maturity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,device,state,maturity);
}

@override
String toString() {
    return 'LiveState(device: $device, state: $state, maturity: $maturity)';
}


}

/// @nodoc
abstract mixin class _$LiveStateCopyWith<$Res> implements $LiveStateCopyWith<$Res> {
  factory _$LiveStateCopyWith(_LiveState value, $Res Function(_LiveState) _then) = __$LiveStateCopyWithImpl;
@override @useResult
$Res call({
 DeviceInfo device, SensorState state, MaturityInfo maturity
});


@override $DeviceInfoCopyWith<$Res> get device;@override $SensorStateCopyWith<$Res> get state;@override $MaturityInfoCopyWith<$Res> get maturity;

}
/// @nodoc
class __$LiveStateCopyWithImpl<$Res>
    implements _$LiveStateCopyWith<$Res> {
  __$LiveStateCopyWithImpl(this._self, this._then);

  final _LiveState _self;
  final $Res Function(_LiveState) _then;

/// Create a copy of LiveState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? device = null,Object? state = null,Object? maturity = null,}) {
  return _then(_LiveState(
device: null == device ? _self.device : device // ignore: cast_nullable_to_non_nullable
as DeviceInfo,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as SensorState,maturity: null == maturity ? _self.maturity : maturity // ignore: cast_nullable_to_non_nullable
as MaturityInfo,
  ));
}

/// Create a copy of LiveState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DeviceInfoCopyWith<$Res> get device {
  
  return $DeviceInfoCopyWith<$Res>(_self.device, (value) {
    return _then(_self.copyWith(device: value));
  });
}/// Create a copy of LiveState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SensorStateCopyWith<$Res> get state {
  
  return $SensorStateCopyWith<$Res>(_self.state, (value) {
    return _then(_self.copyWith(state: value));
  });
}/// Create a copy of LiveState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MaturityInfoCopyWith<$Res> get maturity {
  
  return $MaturityInfoCopyWith<$Res>(_self.maturity, (value) {
    return _then(_self.copyWith(maturity: value));
  });
}
}

// dart format on
