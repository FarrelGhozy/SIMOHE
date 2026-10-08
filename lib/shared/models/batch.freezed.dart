// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'batch.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Batch {

 int get id; String? get label; BatchStatus get status;@JsonKey(name: 'started_at') DateTime? get startedAt;@JsonKey(name: 'matured_at') DateTime? get maturedAt;@JsonKey(name: 'harvested_at') DateTime? get harvestedAt;@JsonKey(name: 'created_at') DateTime? get createdAt;
/// Create a copy of Batch
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BatchCopyWith<Batch> get copyWith => _$BatchCopyWithImpl<Batch>(this as Batch, _$identity);

  /// Serializes this Batch to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Batch;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Batch&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.label, _this.label) || other.label == _this.label)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.startedAt, _this.startedAt) || other.startedAt == _this.startedAt)&&(identical(other.maturedAt, _this.maturedAt) || other.maturedAt == _this.maturedAt)&&(identical(other.harvestedAt, _this.harvestedAt) || other.harvestedAt == _this.harvestedAt)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Batch;
  return Object.hash(runtimeType,_this.id,_this.label,_this.status,_this.startedAt,_this.maturedAt,_this.harvestedAt,_this.createdAt);
}

@override
String toString() {
  final _this = this as Batch;
  return 'Batch(id: ${_this.id}, label: ${_this.label}, status: ${_this.status}, startedAt: ${_this.startedAt}, maturedAt: ${_this.maturedAt}, harvestedAt: ${_this.harvestedAt}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $BatchCopyWith<$Res>  {
  factory $BatchCopyWith(Batch value, $Res Function(Batch) _then) = _$BatchCopyWithImpl;
@useResult
$Res call({
 int id, String? label, BatchStatus status,@JsonKey(name: 'started_at') DateTime? startedAt,@JsonKey(name: 'matured_at') DateTime? maturedAt,@JsonKey(name: 'harvested_at') DateTime? harvestedAt,@JsonKey(name: 'created_at') DateTime? createdAt
});




}
/// @nodoc
class _$BatchCopyWithImpl<$Res>
    implements $BatchCopyWith<$Res> {
  _$BatchCopyWithImpl(this._self, this._then);

  final Batch _self;
  final $Res Function(Batch) _then;

/// Create a copy of Batch
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? label = freezed,Object? status = null,Object? startedAt = freezed,Object? maturedAt = freezed,Object? harvestedAt = freezed,Object? createdAt = freezed,}) {
  return _then(Batch(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BatchStatus,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,maturedAt: freezed == maturedAt ? _self.maturedAt : maturedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,harvestedAt: freezed == harvestedAt ? _self.harvestedAt : harvestedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Batch].
extension BatchPatterns on Batch {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Batch value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Batch() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Batch value)  $default,){
final _that = this;
switch (_that) {
case _Batch():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Batch value)?  $default,){
final _that = this;
switch (_that) {
case _Batch() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String? label,  BatchStatus status, @JsonKey(name: 'started_at')  DateTime? startedAt, @JsonKey(name: 'matured_at')  DateTime? maturedAt, @JsonKey(name: 'harvested_at')  DateTime? harvestedAt, @JsonKey(name: 'created_at')  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Batch() when $default != null:
return $default(_that.id,_that.label,_that.status,_that.startedAt,_that.maturedAt,_that.harvestedAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String? label,  BatchStatus status, @JsonKey(name: 'started_at')  DateTime? startedAt, @JsonKey(name: 'matured_at')  DateTime? maturedAt, @JsonKey(name: 'harvested_at')  DateTime? harvestedAt, @JsonKey(name: 'created_at')  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _Batch():
return $default(_that.id,_that.label,_that.status,_that.startedAt,_that.maturedAt,_that.harvestedAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String? label,  BatchStatus status, @JsonKey(name: 'started_at')  DateTime? startedAt, @JsonKey(name: 'matured_at')  DateTime? maturedAt, @JsonKey(name: 'harvested_at')  DateTime? harvestedAt, @JsonKey(name: 'created_at')  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Batch() when $default != null:
return $default(_that.id,_that.label,_that.status,_that.startedAt,_that.maturedAt,_that.harvestedAt,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Batch implements Batch {
  const _Batch({required this.id, this.label, required this.status, @JsonKey(name: 'started_at') this.startedAt, @JsonKey(name: 'matured_at') this.maturedAt, @JsonKey(name: 'harvested_at') this.harvestedAt, @JsonKey(name: 'created_at') this.createdAt});
  factory _Batch.fromJson(Map<String, dynamic> json) => _$BatchFromJson(json);

@override final  int id;
@override final  String? label;
@override final  BatchStatus status;
@override@JsonKey(name: 'started_at') final  DateTime? startedAt;
@override@JsonKey(name: 'matured_at') final  DateTime? maturedAt;
@override@JsonKey(name: 'harvested_at') final  DateTime? harvestedAt;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;

/// Create a copy of Batch
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BatchCopyWith<_Batch> get copyWith => __$BatchCopyWithImpl<_Batch>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BatchToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Batch&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.status, status) || other.status == status)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.maturedAt, maturedAt) || other.maturedAt == maturedAt)&&(identical(other.harvestedAt, harvestedAt) || other.harvestedAt == harvestedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,label,status,startedAt,maturedAt,harvestedAt,createdAt);
}

@override
String toString() {
    return 'Batch(id: $id, label: $label, status: $status, startedAt: $startedAt, maturedAt: $maturedAt, harvestedAt: $harvestedAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$BatchCopyWith<$Res> implements $BatchCopyWith<$Res> {
  factory _$BatchCopyWith(_Batch value, $Res Function(_Batch) _then) = __$BatchCopyWithImpl;
@override @useResult
$Res call({
 int id, String? label, BatchStatus status,@JsonKey(name: 'started_at') DateTime? startedAt,@JsonKey(name: 'matured_at') DateTime? maturedAt,@JsonKey(name: 'harvested_at') DateTime? harvestedAt,@JsonKey(name: 'created_at') DateTime? createdAt
});




}
/// @nodoc
class __$BatchCopyWithImpl<$Res>
    implements _$BatchCopyWith<$Res> {
  __$BatchCopyWithImpl(this._self, this._then);

  final _Batch _self;
  final $Res Function(_Batch) _then;

/// Create a copy of Batch
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? label = freezed,Object? status = null,Object? startedAt = freezed,Object? maturedAt = freezed,Object? harvestedAt = freezed,Object? createdAt = freezed,}) {
  return _then(_Batch(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BatchStatus,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,maturedAt: freezed == maturedAt ? _self.maturedAt : maturedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,harvestedAt: freezed == harvestedAt ? _self.harvestedAt : harvestedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
