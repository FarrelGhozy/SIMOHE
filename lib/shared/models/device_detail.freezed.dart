// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'device_detail.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DeviceDetail {

 String get id; String get name; String? get location; String? get firmware;@JsonKey(name: 'is_online') bool get isOnline;@JsonKey(name: 'last_seen_at') DateTime? get lastSeenAt;@JsonKey(name: 'created_at') DateTime get createdAt;
/// Create a copy of DeviceDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeviceDetailCopyWith<DeviceDetail> get copyWith => _$DeviceDetailCopyWithImpl<DeviceDetail>(this as DeviceDetail, _$identity);

  /// Serializes this DeviceDetail to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DeviceDetail;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeviceDetail&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.location, _this.location) || other.location == _this.location)&&(identical(other.firmware, _this.firmware) || other.firmware == _this.firmware)&&(identical(other.isOnline, _this.isOnline) || other.isOnline == _this.isOnline)&&(identical(other.lastSeenAt, _this.lastSeenAt) || other.lastSeenAt == _this.lastSeenAt)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DeviceDetail;
  return Object.hash(runtimeType,_this.id,_this.name,_this.location,_this.firmware,_this.isOnline,_this.lastSeenAt,_this.createdAt);
}

@override
String toString() {
  final _this = this as DeviceDetail;
  return 'DeviceDetail(id: ${_this.id}, name: ${_this.name}, location: ${_this.location}, firmware: ${_this.firmware}, isOnline: ${_this.isOnline}, lastSeenAt: ${_this.lastSeenAt}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $DeviceDetailCopyWith<$Res>  {
  factory $DeviceDetailCopyWith(DeviceDetail value, $Res Function(DeviceDetail) _then) = _$DeviceDetailCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? location, String? firmware,@JsonKey(name: 'is_online') bool isOnline,@JsonKey(name: 'last_seen_at') DateTime? lastSeenAt,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class _$DeviceDetailCopyWithImpl<$Res>
    implements $DeviceDetailCopyWith<$Res> {
  _$DeviceDetailCopyWithImpl(this._self, this._then);

  final DeviceDetail _self;
  final $Res Function(DeviceDetail) _then;

/// Create a copy of DeviceDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? location = freezed,Object? firmware = freezed,Object? isOnline = null,Object? lastSeenAt = freezed,Object? createdAt = null,}) {
  return _then(DeviceDetail(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,firmware: freezed == firmware ? _self.firmware : firmware // ignore: cast_nullable_to_non_nullable
as String?,isOnline: null == isOnline ? _self.isOnline : isOnline // ignore: cast_nullable_to_non_nullable
as bool,lastSeenAt: freezed == lastSeenAt ? _self.lastSeenAt : lastSeenAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [DeviceDetail].
extension DeviceDetailPatterns on DeviceDetail {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DeviceDetail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeviceDetail() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DeviceDetail value)  $default,){
final _that = this;
switch (_that) {
case _DeviceDetail():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DeviceDetail value)?  $default,){
final _that = this;
switch (_that) {
case _DeviceDetail() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? location,  String? firmware, @JsonKey(name: 'is_online')  bool isOnline, @JsonKey(name: 'last_seen_at')  DateTime? lastSeenAt, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DeviceDetail() when $default != null:
return $default(_that.id,_that.name,_that.location,_that.firmware,_that.isOnline,_that.lastSeenAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? location,  String? firmware, @JsonKey(name: 'is_online')  bool isOnline, @JsonKey(name: 'last_seen_at')  DateTime? lastSeenAt, @JsonKey(name: 'created_at')  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _DeviceDetail():
return $default(_that.id,_that.name,_that.location,_that.firmware,_that.isOnline,_that.lastSeenAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? location,  String? firmware, @JsonKey(name: 'is_online')  bool isOnline, @JsonKey(name: 'last_seen_at')  DateTime? lastSeenAt, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _DeviceDetail() when $default != null:
return $default(_that.id,_that.name,_that.location,_that.firmware,_that.isOnline,_that.lastSeenAt,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DeviceDetail implements DeviceDetail {
  const _DeviceDetail({required this.id, required this.name, this.location, this.firmware, @JsonKey(name: 'is_online') required this.isOnline, @JsonKey(name: 'last_seen_at') this.lastSeenAt, @JsonKey(name: 'created_at') required this.createdAt});
  factory _DeviceDetail.fromJson(Map<String, dynamic> json) => _$DeviceDetailFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? location;
@override final  String? firmware;
@override@JsonKey(name: 'is_online') final  bool isOnline;
@override@JsonKey(name: 'last_seen_at') final  DateTime? lastSeenAt;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;

/// Create a copy of DeviceDetail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeviceDetailCopyWith<_DeviceDetail> get copyWith => __$DeviceDetailCopyWithImpl<_DeviceDetail>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DeviceDetailToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeviceDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.location, location) || other.location == location)&&(identical(other.firmware, firmware) || other.firmware == firmware)&&(identical(other.isOnline, isOnline) || other.isOnline == isOnline)&&(identical(other.lastSeenAt, lastSeenAt) || other.lastSeenAt == lastSeenAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,location,firmware,isOnline,lastSeenAt,createdAt);
}

@override
String toString() {
    return 'DeviceDetail(id: $id, name: $name, location: $location, firmware: $firmware, isOnline: $isOnline, lastSeenAt: $lastSeenAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$DeviceDetailCopyWith<$Res> implements $DeviceDetailCopyWith<$Res> {
  factory _$DeviceDetailCopyWith(_DeviceDetail value, $Res Function(_DeviceDetail) _then) = __$DeviceDetailCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? location, String? firmware,@JsonKey(name: 'is_online') bool isOnline,@JsonKey(name: 'last_seen_at') DateTime? lastSeenAt,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class __$DeviceDetailCopyWithImpl<$Res>
    implements _$DeviceDetailCopyWith<$Res> {
  __$DeviceDetailCopyWithImpl(this._self, this._then);

  final _DeviceDetail _self;
  final $Res Function(_DeviceDetail) _then;

/// Create a copy of DeviceDetail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? location = freezed,Object? firmware = freezed,Object? isOnline = null,Object? lastSeenAt = freezed,Object? createdAt = null,}) {
  return _then(_DeviceDetail(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,firmware: freezed == firmware ? _self.firmware : firmware // ignore: cast_nullable_to_non_nullable
as String?,isOnline: null == isOnline ? _self.isOnline : isOnline // ignore: cast_nullable_to_non_nullable
as bool,lastSeenAt: freezed == lastSeenAt ? _self.lastSeenAt : lastSeenAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
