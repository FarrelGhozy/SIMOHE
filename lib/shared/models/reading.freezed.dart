// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reading.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReadingPoint {

 DateTime? get ts;@JsonKey(name: 'temp_c') double? get tempC;@JsonKey(name: 'nh3_ppm') double? get nh3Ppm;@JsonKey(name: 'heater_on') bool get heaterOn;@JsonKey(name: 'valve_open') bool get valveOpen;
/// Create a copy of ReadingPoint
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReadingPointCopyWith<ReadingPoint> get copyWith => _$ReadingPointCopyWithImpl<ReadingPoint>(this as ReadingPoint, _$identity);

  /// Serializes this ReadingPoint to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ReadingPoint;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReadingPoint&&(identical(other.ts, _this.ts) || other.ts == _this.ts)&&(identical(other.tempC, _this.tempC) || other.tempC == _this.tempC)&&(identical(other.nh3Ppm, _this.nh3Ppm) || other.nh3Ppm == _this.nh3Ppm)&&(identical(other.heaterOn, _this.heaterOn) || other.heaterOn == _this.heaterOn)&&(identical(other.valveOpen, _this.valveOpen) || other.valveOpen == _this.valveOpen));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ReadingPoint;
  return Object.hash(runtimeType,_this.ts,_this.tempC,_this.nh3Ppm,_this.heaterOn,_this.valveOpen);
}

@override
String toString() {
  final _this = this as ReadingPoint;
  return 'ReadingPoint(ts: ${_this.ts}, tempC: ${_this.tempC}, nh3Ppm: ${_this.nh3Ppm}, heaterOn: ${_this.heaterOn}, valveOpen: ${_this.valveOpen})';
}


}

/// @nodoc
abstract mixin class $ReadingPointCopyWith<$Res>  {
  factory $ReadingPointCopyWith(ReadingPoint value, $Res Function(ReadingPoint) _then) = _$ReadingPointCopyWithImpl;
@useResult
$Res call({
 DateTime? ts,@JsonKey(name: 'temp_c') double? tempC,@JsonKey(name: 'nh3_ppm') double? nh3Ppm,@JsonKey(name: 'heater_on') bool heaterOn,@JsonKey(name: 'valve_open') bool valveOpen
});




}
/// @nodoc
class _$ReadingPointCopyWithImpl<$Res>
    implements $ReadingPointCopyWith<$Res> {
  _$ReadingPointCopyWithImpl(this._self, this._then);

  final ReadingPoint _self;
  final $Res Function(ReadingPoint) _then;

/// Create a copy of ReadingPoint
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ts = freezed,Object? tempC = freezed,Object? nh3Ppm = freezed,Object? heaterOn = null,Object? valveOpen = null,}) {
  return _then(ReadingPoint(
ts: freezed == ts ? _self.ts : ts // ignore: cast_nullable_to_non_nullable
as DateTime?,tempC: freezed == tempC ? _self.tempC : tempC // ignore: cast_nullable_to_non_nullable
as double?,nh3Ppm: freezed == nh3Ppm ? _self.nh3Ppm : nh3Ppm // ignore: cast_nullable_to_non_nullable
as double?,heaterOn: null == heaterOn ? _self.heaterOn : heaterOn // ignore: cast_nullable_to_non_nullable
as bool,valveOpen: null == valveOpen ? _self.valveOpen : valveOpen // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ReadingPoint].
extension ReadingPointPatterns on ReadingPoint {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReadingPoint value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReadingPoint() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReadingPoint value)  $default,){
final _that = this;
switch (_that) {
case _ReadingPoint():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReadingPoint value)?  $default,){
final _that = this;
switch (_that) {
case _ReadingPoint() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime? ts, @JsonKey(name: 'temp_c')  double? tempC, @JsonKey(name: 'nh3_ppm')  double? nh3Ppm, @JsonKey(name: 'heater_on')  bool heaterOn, @JsonKey(name: 'valve_open')  bool valveOpen)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReadingPoint() when $default != null:
return $default(_that.ts,_that.tempC,_that.nh3Ppm,_that.heaterOn,_that.valveOpen);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime? ts, @JsonKey(name: 'temp_c')  double? tempC, @JsonKey(name: 'nh3_ppm')  double? nh3Ppm, @JsonKey(name: 'heater_on')  bool heaterOn, @JsonKey(name: 'valve_open')  bool valveOpen)  $default,) {final _that = this;
switch (_that) {
case _ReadingPoint():
return $default(_that.ts,_that.tempC,_that.nh3Ppm,_that.heaterOn,_that.valveOpen);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime? ts, @JsonKey(name: 'temp_c')  double? tempC, @JsonKey(name: 'nh3_ppm')  double? nh3Ppm, @JsonKey(name: 'heater_on')  bool heaterOn, @JsonKey(name: 'valve_open')  bool valveOpen)?  $default,) {final _that = this;
switch (_that) {
case _ReadingPoint() when $default != null:
return $default(_that.ts,_that.tempC,_that.nh3Ppm,_that.heaterOn,_that.valveOpen);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReadingPoint implements ReadingPoint {
  const _ReadingPoint({this.ts, @JsonKey(name: 'temp_c') this.tempC, @JsonKey(name: 'nh3_ppm') this.nh3Ppm, @JsonKey(name: 'heater_on') required this.heaterOn, @JsonKey(name: 'valve_open') required this.valveOpen});
  factory _ReadingPoint.fromJson(Map<String, dynamic> json) => _$ReadingPointFromJson(json);

@override final  DateTime? ts;
@override@JsonKey(name: 'temp_c') final  double? tempC;
@override@JsonKey(name: 'nh3_ppm') final  double? nh3Ppm;
@override@JsonKey(name: 'heater_on') final  bool heaterOn;
@override@JsonKey(name: 'valve_open') final  bool valveOpen;

/// Create a copy of ReadingPoint
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReadingPointCopyWith<_ReadingPoint> get copyWith => __$ReadingPointCopyWithImpl<_ReadingPoint>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReadingPointToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReadingPoint&&(identical(other.ts, ts) || other.ts == ts)&&(identical(other.tempC, tempC) || other.tempC == tempC)&&(identical(other.nh3Ppm, nh3Ppm) || other.nh3Ppm == nh3Ppm)&&(identical(other.heaterOn, heaterOn) || other.heaterOn == heaterOn)&&(identical(other.valveOpen, valveOpen) || other.valveOpen == valveOpen));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,ts,tempC,nh3Ppm,heaterOn,valveOpen);
}

@override
String toString() {
    return 'ReadingPoint(ts: $ts, tempC: $tempC, nh3Ppm: $nh3Ppm, heaterOn: $heaterOn, valveOpen: $valveOpen)';
}


}

/// @nodoc
abstract mixin class _$ReadingPointCopyWith<$Res> implements $ReadingPointCopyWith<$Res> {
  factory _$ReadingPointCopyWith(_ReadingPoint value, $Res Function(_ReadingPoint) _then) = __$ReadingPointCopyWithImpl;
@override @useResult
$Res call({
 DateTime? ts,@JsonKey(name: 'temp_c') double? tempC,@JsonKey(name: 'nh3_ppm') double? nh3Ppm,@JsonKey(name: 'heater_on') bool heaterOn,@JsonKey(name: 'valve_open') bool valveOpen
});




}
/// @nodoc
class __$ReadingPointCopyWithImpl<$Res>
    implements _$ReadingPointCopyWith<$Res> {
  __$ReadingPointCopyWithImpl(this._self, this._then);

  final _ReadingPoint _self;
  final $Res Function(_ReadingPoint) _then;

/// Create a copy of ReadingPoint
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ts = freezed,Object? tempC = freezed,Object? nh3Ppm = freezed,Object? heaterOn = null,Object? valveOpen = null,}) {
  return _then(_ReadingPoint(
ts: freezed == ts ? _self.ts : ts // ignore: cast_nullable_to_non_nullable
as DateTime?,tempC: freezed == tempC ? _self.tempC : tempC // ignore: cast_nullable_to_non_nullable
as double?,nh3Ppm: freezed == nh3Ppm ? _self.nh3Ppm : nh3Ppm // ignore: cast_nullable_to_non_nullable
as double?,heaterOn: null == heaterOn ? _self.heaterOn : heaterOn // ignore: cast_nullable_to_non_nullable
as bool,valveOpen: null == valveOpen ? _self.valveOpen : valveOpen // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$ReadingsResponse {

 ReadingBucket get bucket; DateTime? get from; DateTime? get to; List<ReadingPoint> get items;
/// Create a copy of ReadingsResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReadingsResponseCopyWith<ReadingsResponse> get copyWith => _$ReadingsResponseCopyWithImpl<ReadingsResponse>(this as ReadingsResponse, _$identity);

  /// Serializes this ReadingsResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ReadingsResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReadingsResponse&&(identical(other.bucket, _this.bucket) || other.bucket == _this.bucket)&&(identical(other.from, _this.from) || other.from == _this.from)&&(identical(other.to, _this.to) || other.to == _this.to)&&const DeepCollectionEquality().equals(other.items, _this.items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ReadingsResponse;
  return Object.hash(runtimeType,_this.bucket,_this.from,_this.to,const DeepCollectionEquality().hash(_this.items));
}

@override
String toString() {
  final _this = this as ReadingsResponse;
  return 'ReadingsResponse(bucket: ${_this.bucket}, from: ${_this.from}, to: ${_this.to}, items: ${_this.items})';
}


}

/// @nodoc
abstract mixin class $ReadingsResponseCopyWith<$Res>  {
  factory $ReadingsResponseCopyWith(ReadingsResponse value, $Res Function(ReadingsResponse) _then) = _$ReadingsResponseCopyWithImpl;
@useResult
$Res call({
 ReadingBucket bucket, DateTime? from, DateTime? to, List<ReadingPoint> items
});




}
/// @nodoc
class _$ReadingsResponseCopyWithImpl<$Res>
    implements $ReadingsResponseCopyWith<$Res> {
  _$ReadingsResponseCopyWithImpl(this._self, this._then);

  final ReadingsResponse _self;
  final $Res Function(ReadingsResponse) _then;

/// Create a copy of ReadingsResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bucket = null,Object? from = freezed,Object? to = freezed,Object? items = null,}) {
  return _then(ReadingsResponse(
bucket: null == bucket ? _self.bucket : bucket // ignore: cast_nullable_to_non_nullable
as ReadingBucket,from: freezed == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as DateTime?,to: freezed == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as DateTime?,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<ReadingPoint>,
  ));
}

}


/// Adds pattern-matching-related methods to [ReadingsResponse].
extension ReadingsResponsePatterns on ReadingsResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReadingsResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReadingsResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReadingsResponse value)  $default,){
final _that = this;
switch (_that) {
case _ReadingsResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReadingsResponse value)?  $default,){
final _that = this;
switch (_that) {
case _ReadingsResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ReadingBucket bucket,  DateTime? from,  DateTime? to,  List<ReadingPoint> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReadingsResponse() when $default != null:
return $default(_that.bucket,_that.from,_that.to,_that.items);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ReadingBucket bucket,  DateTime? from,  DateTime? to,  List<ReadingPoint> items)  $default,) {final _that = this;
switch (_that) {
case _ReadingsResponse():
return $default(_that.bucket,_that.from,_that.to,_that.items);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ReadingBucket bucket,  DateTime? from,  DateTime? to,  List<ReadingPoint> items)?  $default,) {final _that = this;
switch (_that) {
case _ReadingsResponse() when $default != null:
return $default(_that.bucket,_that.from,_that.to,_that.items);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReadingsResponse implements ReadingsResponse {
  const _ReadingsResponse({required this.bucket, this.from, this.to,  List<ReadingPoint> items = const <ReadingPoint>[]}): _items = items;
  factory _ReadingsResponse.fromJson(Map<String, dynamic> json) => _$ReadingsResponseFromJson(json);

@override final  ReadingBucket bucket;
@override final  DateTime? from;
@override final  DateTime? to;
 final  List<ReadingPoint> _items;
@override@JsonKey() List<ReadingPoint> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of ReadingsResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReadingsResponseCopyWith<_ReadingsResponse> get copyWith => __$ReadingsResponseCopyWithImpl<_ReadingsResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReadingsResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReadingsResponse&&(identical(other.bucket, bucket) || other.bucket == bucket)&&(identical(other.from, from) || other.from == from)&&(identical(other.to, to) || other.to == to)&&const DeepCollectionEquality().equals(other.items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,bucket,from,to,const DeepCollectionEquality().hash(_items));
}

@override
String toString() {
    return 'ReadingsResponse(bucket: $bucket, from: $from, to: $to, items: $items)';
}


}

/// @nodoc
abstract mixin class _$ReadingsResponseCopyWith<$Res> implements $ReadingsResponseCopyWith<$Res> {
  factory _$ReadingsResponseCopyWith(_ReadingsResponse value, $Res Function(_ReadingsResponse) _then) = __$ReadingsResponseCopyWithImpl;
@override @useResult
$Res call({
 ReadingBucket bucket, DateTime? from, DateTime? to, List<ReadingPoint> items
});




}
/// @nodoc
class __$ReadingsResponseCopyWithImpl<$Res>
    implements _$ReadingsResponseCopyWith<$Res> {
  __$ReadingsResponseCopyWithImpl(this._self, this._then);

  final _ReadingsResponse _self;
  final $Res Function(_ReadingsResponse) _then;

/// Create a copy of ReadingsResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bucket = null,Object? from = freezed,Object? to = freezed,Object? items = null,}) {
  return _then(_ReadingsResponse(
bucket: null == bucket ? _self.bucket : bucket // ignore: cast_nullable_to_non_nullable
as ReadingBucket,from: freezed == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as DateTime?,to: freezed == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as DateTime?,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<ReadingPoint>,
  ));
}


}

// dart format on
