// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MetricStats {

 double? get min; double? get max; double? get avg;
/// Create a copy of MetricStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MetricStatsCopyWith<MetricStats> get copyWith => _$MetricStatsCopyWithImpl<MetricStats>(this as MetricStats, _$identity);

  /// Serializes this MetricStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as MetricStats;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MetricStats&&(identical(other.min, _this.min) || other.min == _this.min)&&(identical(other.max, _this.max) || other.max == _this.max)&&(identical(other.avg, _this.avg) || other.avg == _this.avg));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MetricStats;
  return Object.hash(runtimeType,_this.min,_this.max,_this.avg);
}

@override
String toString() {
  final _this = this as MetricStats;
  return 'MetricStats(min: ${_this.min}, max: ${_this.max}, avg: ${_this.avg})';
}


}

/// @nodoc
abstract mixin class $MetricStatsCopyWith<$Res>  {
  factory $MetricStatsCopyWith(MetricStats value, $Res Function(MetricStats) _then) = _$MetricStatsCopyWithImpl;
@useResult
$Res call({
 double? min, double? max, double? avg
});




}
/// @nodoc
class _$MetricStatsCopyWithImpl<$Res>
    implements $MetricStatsCopyWith<$Res> {
  _$MetricStatsCopyWithImpl(this._self, this._then);

  final MetricStats _self;
  final $Res Function(MetricStats) _then;

/// Create a copy of MetricStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? min = freezed,Object? max = freezed,Object? avg = freezed,}) {
  return _then(MetricStats(
min: freezed == min ? _self.min : min // ignore: cast_nullable_to_non_nullable
as double?,max: freezed == max ? _self.max : max // ignore: cast_nullable_to_non_nullable
as double?,avg: freezed == avg ? _self.avg : avg // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [MetricStats].
extension MetricStatsPatterns on MetricStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MetricStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MetricStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MetricStats value)  $default,){
final _that = this;
switch (_that) {
case _MetricStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MetricStats value)?  $default,){
final _that = this;
switch (_that) {
case _MetricStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double? min,  double? max,  double? avg)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MetricStats() when $default != null:
return $default(_that.min,_that.max,_that.avg);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double? min,  double? max,  double? avg)  $default,) {final _that = this;
switch (_that) {
case _MetricStats():
return $default(_that.min,_that.max,_that.avg);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double? min,  double? max,  double? avg)?  $default,) {final _that = this;
switch (_that) {
case _MetricStats() when $default != null:
return $default(_that.min,_that.max,_that.avg);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MetricStats implements MetricStats {
  const _MetricStats({this.min, this.max, this.avg});
  factory _MetricStats.fromJson(Map<String, dynamic> json) => _$MetricStatsFromJson(json);

@override final  double? min;
@override final  double? max;
@override final  double? avg;

/// Create a copy of MetricStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MetricStatsCopyWith<_MetricStats> get copyWith => __$MetricStatsCopyWithImpl<_MetricStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MetricStatsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MetricStats&&(identical(other.min, min) || other.min == min)&&(identical(other.max, max) || other.max == max)&&(identical(other.avg, avg) || other.avg == avg));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,min,max,avg);
}

@override
String toString() {
    return 'MetricStats(min: $min, max: $max, avg: $avg)';
}


}

/// @nodoc
abstract mixin class _$MetricStatsCopyWith<$Res> implements $MetricStatsCopyWith<$Res> {
  factory _$MetricStatsCopyWith(_MetricStats value, $Res Function(_MetricStats) _then) = __$MetricStatsCopyWithImpl;
@override @useResult
$Res call({
 double? min, double? max, double? avg
});




}
/// @nodoc
class __$MetricStatsCopyWithImpl<$Res>
    implements _$MetricStatsCopyWith<$Res> {
  __$MetricStatsCopyWithImpl(this._self, this._then);

  final _MetricStats _self;
  final $Res Function(_MetricStats) _then;

/// Create a copy of MetricStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? min = freezed,Object? max = freezed,Object? avg = freezed,}) {
  return _then(_MetricStats(
min: freezed == min ? _self.min : min // ignore: cast_nullable_to_non_nullable
as double?,max: freezed == max ? _self.max : max // ignore: cast_nullable_to_non_nullable
as double?,avg: freezed == avg ? _self.avg : avg // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}


/// @nodoc
mixin _$SummaryResponse {

 DateTime get from; DateTime get to;@JsonKey(name: 'range_count') int get rangeCount;@JsonKey(name: 'temp_c') MetricStats get tempC;@JsonKey(name: 'nh3_ppm') MetricStats get nh3Ppm;
/// Create a copy of SummaryResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SummaryResponseCopyWith<SummaryResponse> get copyWith => _$SummaryResponseCopyWithImpl<SummaryResponse>(this as SummaryResponse, _$identity);

  /// Serializes this SummaryResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SummaryResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SummaryResponse&&(identical(other.from, _this.from) || other.from == _this.from)&&(identical(other.to, _this.to) || other.to == _this.to)&&(identical(other.rangeCount, _this.rangeCount) || other.rangeCount == _this.rangeCount)&&(identical(other.tempC, _this.tempC) || other.tempC == _this.tempC)&&(identical(other.nh3Ppm, _this.nh3Ppm) || other.nh3Ppm == _this.nh3Ppm));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SummaryResponse;
  return Object.hash(runtimeType,_this.from,_this.to,_this.rangeCount,_this.tempC,_this.nh3Ppm);
}

@override
String toString() {
  final _this = this as SummaryResponse;
  return 'SummaryResponse(from: ${_this.from}, to: ${_this.to}, rangeCount: ${_this.rangeCount}, tempC: ${_this.tempC}, nh3Ppm: ${_this.nh3Ppm})';
}


}

/// @nodoc
abstract mixin class $SummaryResponseCopyWith<$Res>  {
  factory $SummaryResponseCopyWith(SummaryResponse value, $Res Function(SummaryResponse) _then) = _$SummaryResponseCopyWithImpl;
@useResult
$Res call({
 DateTime from, DateTime to,@JsonKey(name: 'range_count') int rangeCount,@JsonKey(name: 'temp_c') MetricStats tempC,@JsonKey(name: 'nh3_ppm') MetricStats nh3Ppm
});


$MetricStatsCopyWith<$Res> get tempC;$MetricStatsCopyWith<$Res> get nh3Ppm;

}
/// @nodoc
class _$SummaryResponseCopyWithImpl<$Res>
    implements $SummaryResponseCopyWith<$Res> {
  _$SummaryResponseCopyWithImpl(this._self, this._then);

  final SummaryResponse _self;
  final $Res Function(SummaryResponse) _then;

/// Create a copy of SummaryResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? from = null,Object? to = null,Object? rangeCount = null,Object? tempC = null,Object? nh3Ppm = null,}) {
  return _then(SummaryResponse(
from: null == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as DateTime,to: null == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as DateTime,rangeCount: null == rangeCount ? _self.rangeCount : rangeCount // ignore: cast_nullable_to_non_nullable
as int,tempC: null == tempC ? _self.tempC : tempC // ignore: cast_nullable_to_non_nullable
as MetricStats,nh3Ppm: null == nh3Ppm ? _self.nh3Ppm : nh3Ppm // ignore: cast_nullable_to_non_nullable
as MetricStats,
  ));
}
/// Create a copy of SummaryResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MetricStatsCopyWith<$Res> get tempC {
  
  return $MetricStatsCopyWith<$Res>(_self.tempC, (value) {
    return _then(_self.copyWith(tempC: value));
  });
}/// Create a copy of SummaryResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MetricStatsCopyWith<$Res> get nh3Ppm {
  
  return $MetricStatsCopyWith<$Res>(_self.nh3Ppm, (value) {
    return _then(_self.copyWith(nh3Ppm: value));
  });
}
}


/// Adds pattern-matching-related methods to [SummaryResponse].
extension SummaryResponsePatterns on SummaryResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SummaryResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SummaryResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SummaryResponse value)  $default,){
final _that = this;
switch (_that) {
case _SummaryResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SummaryResponse value)?  $default,){
final _that = this;
switch (_that) {
case _SummaryResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime from,  DateTime to, @JsonKey(name: 'range_count')  int rangeCount, @JsonKey(name: 'temp_c')  MetricStats tempC, @JsonKey(name: 'nh3_ppm')  MetricStats nh3Ppm)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SummaryResponse() when $default != null:
return $default(_that.from,_that.to,_that.rangeCount,_that.tempC,_that.nh3Ppm);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime from,  DateTime to, @JsonKey(name: 'range_count')  int rangeCount, @JsonKey(name: 'temp_c')  MetricStats tempC, @JsonKey(name: 'nh3_ppm')  MetricStats nh3Ppm)  $default,) {final _that = this;
switch (_that) {
case _SummaryResponse():
return $default(_that.from,_that.to,_that.rangeCount,_that.tempC,_that.nh3Ppm);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime from,  DateTime to, @JsonKey(name: 'range_count')  int rangeCount, @JsonKey(name: 'temp_c')  MetricStats tempC, @JsonKey(name: 'nh3_ppm')  MetricStats nh3Ppm)?  $default,) {final _that = this;
switch (_that) {
case _SummaryResponse() when $default != null:
return $default(_that.from,_that.to,_that.rangeCount,_that.tempC,_that.nh3Ppm);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SummaryResponse implements SummaryResponse {
  const _SummaryResponse({required this.from, required this.to, @JsonKey(name: 'range_count') this.rangeCount = 0, @JsonKey(name: 'temp_c') required this.tempC, @JsonKey(name: 'nh3_ppm') required this.nh3Ppm});
  factory _SummaryResponse.fromJson(Map<String, dynamic> json) => _$SummaryResponseFromJson(json);

@override final  DateTime from;
@override final  DateTime to;
@override@JsonKey(name: 'range_count') final  int rangeCount;
@override@JsonKey(name: 'temp_c') final  MetricStats tempC;
@override@JsonKey(name: 'nh3_ppm') final  MetricStats nh3Ppm;

/// Create a copy of SummaryResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SummaryResponseCopyWith<_SummaryResponse> get copyWith => __$SummaryResponseCopyWithImpl<_SummaryResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SummaryResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SummaryResponse&&(identical(other.from, from) || other.from == from)&&(identical(other.to, to) || other.to == to)&&(identical(other.rangeCount, rangeCount) || other.rangeCount == rangeCount)&&(identical(other.tempC, tempC) || other.tempC == tempC)&&(identical(other.nh3Ppm, nh3Ppm) || other.nh3Ppm == nh3Ppm));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,from,to,rangeCount,tempC,nh3Ppm);
}

@override
String toString() {
    return 'SummaryResponse(from: $from, to: $to, rangeCount: $rangeCount, tempC: $tempC, nh3Ppm: $nh3Ppm)';
}


}

/// @nodoc
abstract mixin class _$SummaryResponseCopyWith<$Res> implements $SummaryResponseCopyWith<$Res> {
  factory _$SummaryResponseCopyWith(_SummaryResponse value, $Res Function(_SummaryResponse) _then) = __$SummaryResponseCopyWithImpl;
@override @useResult
$Res call({
 DateTime from, DateTime to,@JsonKey(name: 'range_count') int rangeCount,@JsonKey(name: 'temp_c') MetricStats tempC,@JsonKey(name: 'nh3_ppm') MetricStats nh3Ppm
});


@override $MetricStatsCopyWith<$Res> get tempC;@override $MetricStatsCopyWith<$Res> get nh3Ppm;

}
/// @nodoc
class __$SummaryResponseCopyWithImpl<$Res>
    implements _$SummaryResponseCopyWith<$Res> {
  __$SummaryResponseCopyWithImpl(this._self, this._then);

  final _SummaryResponse _self;
  final $Res Function(_SummaryResponse) _then;

/// Create a copy of SummaryResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? from = null,Object? to = null,Object? rangeCount = null,Object? tempC = null,Object? nh3Ppm = null,}) {
  return _then(_SummaryResponse(
from: null == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as DateTime,to: null == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as DateTime,rangeCount: null == rangeCount ? _self.rangeCount : rangeCount // ignore: cast_nullable_to_non_nullable
as int,tempC: null == tempC ? _self.tempC : tempC // ignore: cast_nullable_to_non_nullable
as MetricStats,nh3Ppm: null == nh3Ppm ? _self.nh3Ppm : nh3Ppm // ignore: cast_nullable_to_non_nullable
as MetricStats,
  ));
}

/// Create a copy of SummaryResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MetricStatsCopyWith<$Res> get tempC {
  
  return $MetricStatsCopyWith<$Res>(_self.tempC, (value) {
    return _then(_self.copyWith(tempC: value));
  });
}/// Create a copy of SummaryResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MetricStatsCopyWith<$Res> get nh3Ppm {
  
  return $MetricStatsCopyWith<$Res>(_self.nh3Ppm, (value) {
    return _then(_self.copyWith(nh3Ppm: value));
  });
}
}

// dart format on
