// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'device_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DeviceInfo {

 String get id; String get name; String? get location; bool get online;@JsonKey(name: 'last_seen_at') DateTime? get lastSeenAt; String? get firmware;
/// Create a copy of DeviceInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeviceInfoCopyWith<DeviceInfo> get copyWith => _$DeviceInfoCopyWithImpl<DeviceInfo>(this as DeviceInfo, _$identity);

  /// Serializes this DeviceInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DeviceInfo;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeviceInfo&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.location, _this.location) || other.location == _this.location)&&(identical(other.online, _this.online) || other.online == _this.online)&&(identical(other.lastSeenAt, _this.lastSeenAt) || other.lastSeenAt == _this.lastSeenAt)&&(identical(other.firmware, _this.firmware) || other.firmware == _this.firmware));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DeviceInfo;
  return Object.hash(runtimeType,_this.id,_this.name,_this.location,_this.online,_this.lastSeenAt,_this.firmware);
}

@override
String toString() {
  final _this = this as DeviceInfo;
  return 'DeviceInfo(id: ${_this.id}, name: ${_this.name}, location: ${_this.location}, online: ${_this.online}, lastSeenAt: ${_this.lastSeenAt}, firmware: ${_this.firmware})';
}


}

/// @nodoc
abstract mixin class $DeviceInfoCopyWith<$Res>  {
  factory $DeviceInfoCopyWith(DeviceInfo value, $Res Function(DeviceInfo) _then) = _$DeviceInfoCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? location, bool online,@JsonKey(name: 'last_seen_at') DateTime? lastSeenAt, String? firmware
});




}
/// @nodoc
class _$DeviceInfoCopyWithImpl<$Res>
    implements $DeviceInfoCopyWith<$Res> {
  _$DeviceInfoCopyWithImpl(this._self, this._then);

  final DeviceInfo _self;
  final $Res Function(DeviceInfo) _then;

/// Create a copy of DeviceInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? location = freezed,Object? online = null,Object? lastSeenAt = freezed,Object? firmware = freezed,}) {
  return _then(DeviceInfo(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,online: null == online ? _self.online : online // ignore: cast_nullable_to_non_nullable
as bool,lastSeenAt: freezed == lastSeenAt ? _self.lastSeenAt : lastSeenAt // ignore: cast_nullable_to_non_nullable
as DateTime?,firmware: freezed == firmware ? _self.firmware : firmware // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DeviceInfo].
extension DeviceInfoPatterns on DeviceInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DeviceInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeviceInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DeviceInfo value)  $default,){
final _that = this;
switch (_that) {
case _DeviceInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DeviceInfo value)?  $default,){
final _that = this;
switch (_that) {
case _DeviceInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? location,  bool online, @JsonKey(name: 'last_seen_at')  DateTime? lastSeenAt,  String? firmware)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DeviceInfo() when $default != null:
return $default(_that.id,_that.name,_that.location,_that.online,_that.lastSeenAt,_that.firmware);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? location,  bool online, @JsonKey(name: 'last_seen_at')  DateTime? lastSeenAt,  String? firmware)  $default,) {final _that = this;
switch (_that) {
case _DeviceInfo():
return $default(_that.id,_that.name,_that.location,_that.online,_that.lastSeenAt,_that.firmware);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? location,  bool online, @JsonKey(name: 'last_seen_at')  DateTime? lastSeenAt,  String? firmware)?  $default,) {final _that = this;
switch (_that) {
case _DeviceInfo() when $default != null:
return $default(_that.id,_that.name,_that.location,_that.online,_that.lastSeenAt,_that.firmware);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DeviceInfo implements DeviceInfo {
  const _DeviceInfo({required this.id, required this.name, this.location, required this.online, @JsonKey(name: 'last_seen_at') this.lastSeenAt, this.firmware});
  factory _DeviceInfo.fromJson(Map<String, dynamic> json) => _$DeviceInfoFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? location;
@override final  bool online;
@override@JsonKey(name: 'last_seen_at') final  DateTime? lastSeenAt;
@override final  String? firmware;

/// Create a copy of DeviceInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeviceInfoCopyWith<_DeviceInfo> get copyWith => __$DeviceInfoCopyWithImpl<_DeviceInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DeviceInfoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeviceInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.location, location) || other.location == location)&&(identical(other.online, online) || other.online == online)&&(identical(other.lastSeenAt, lastSeenAt) || other.lastSeenAt == lastSeenAt)&&(identical(other.firmware, firmware) || other.firmware == firmware));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,location,online,lastSeenAt,firmware);
}

@override
String toString() {
    return 'DeviceInfo(id: $id, name: $name, location: $location, online: $online, lastSeenAt: $lastSeenAt, firmware: $firmware)';
}


}

/// @nodoc
abstract mixin class _$DeviceInfoCopyWith<$Res> implements $DeviceInfoCopyWith<$Res> {
  factory _$DeviceInfoCopyWith(_DeviceInfo value, $Res Function(_DeviceInfo) _then) = __$DeviceInfoCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? location, bool online,@JsonKey(name: 'last_seen_at') DateTime? lastSeenAt, String? firmware
});




}
/// @nodoc
class __$DeviceInfoCopyWithImpl<$Res>
    implements _$DeviceInfoCopyWith<$Res> {
  __$DeviceInfoCopyWithImpl(this._self, this._then);

  final _DeviceInfo _self;
  final $Res Function(_DeviceInfo) _then;

/// Create a copy of DeviceInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? location = freezed,Object? online = null,Object? lastSeenAt = freezed,Object? firmware = freezed,}) {
  return _then(_DeviceInfo(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,online: null == online ? _self.online : online // ignore: cast_nullable_to_non_nullable
as bool,lastSeenAt: freezed == lastSeenAt ? _self.lastSeenAt : lastSeenAt // ignore: cast_nullable_to_non_nullable
as DateTime?,firmware: freezed == firmware ? _self.firmware : firmware // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
