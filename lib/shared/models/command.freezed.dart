// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'command.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Command {

 String get id; CommandAction get action; CommandStatus get status; Map<String, dynamic> get args;@JsonKey(name: 'created_at') DateTime? get createdAt;@JsonKey(name: 'sent_at') DateTime? get sentAt;@JsonKey(name: 'acked_at') DateTime? get ackedAt;@JsonKey(name: 'expires_at') DateTime? get expiresAt;
/// Create a copy of Command
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommandCopyWith<Command> get copyWith => _$CommandCopyWithImpl<Command>(this as Command, _$identity);

  /// Serializes this Command to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Command;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Command&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.action, _this.action) || other.action == _this.action)&&(identical(other.status, _this.status) || other.status == _this.status)&&const DeepCollectionEquality().equals(other.args, _this.args)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.sentAt, _this.sentAt) || other.sentAt == _this.sentAt)&&(identical(other.ackedAt, _this.ackedAt) || other.ackedAt == _this.ackedAt)&&(identical(other.expiresAt, _this.expiresAt) || other.expiresAt == _this.expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Command;
  return Object.hash(runtimeType,_this.id,_this.action,_this.status,const DeepCollectionEquality().hash(_this.args),_this.createdAt,_this.sentAt,_this.ackedAt,_this.expiresAt);
}

@override
String toString() {
  final _this = this as Command;
  return 'Command(id: ${_this.id}, action: ${_this.action}, status: ${_this.status}, args: ${_this.args}, createdAt: ${_this.createdAt}, sentAt: ${_this.sentAt}, ackedAt: ${_this.ackedAt}, expiresAt: ${_this.expiresAt})';
}


}

/// @nodoc
abstract mixin class $CommandCopyWith<$Res>  {
  factory $CommandCopyWith(Command value, $Res Function(Command) _then) = _$CommandCopyWithImpl;
@useResult
$Res call({
 String id, CommandAction action, CommandStatus status, Map<String, dynamic> args,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'sent_at') DateTime? sentAt,@JsonKey(name: 'acked_at') DateTime? ackedAt,@JsonKey(name: 'expires_at') DateTime? expiresAt
});




}
/// @nodoc
class _$CommandCopyWithImpl<$Res>
    implements $CommandCopyWith<$Res> {
  _$CommandCopyWithImpl(this._self, this._then);

  final Command _self;
  final $Res Function(Command) _then;

/// Create a copy of Command
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? action = null,Object? status = null,Object? args = null,Object? createdAt = freezed,Object? sentAt = freezed,Object? ackedAt = freezed,Object? expiresAt = freezed,}) {
  return _then(Command(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as CommandAction,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CommandStatus,args: null == args ? _self.args : args // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,sentAt: freezed == sentAt ? _self.sentAt : sentAt // ignore: cast_nullable_to_non_nullable
as DateTime?,ackedAt: freezed == ackedAt ? _self.ackedAt : ackedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Command].
extension CommandPatterns on Command {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Command value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Command() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Command value)  $default,){
final _that = this;
switch (_that) {
case _Command():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Command value)?  $default,){
final _that = this;
switch (_that) {
case _Command() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  CommandAction action,  CommandStatus status,  Map<String, dynamic> args, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'sent_at')  DateTime? sentAt, @JsonKey(name: 'acked_at')  DateTime? ackedAt, @JsonKey(name: 'expires_at')  DateTime? expiresAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Command() when $default != null:
return $default(_that.id,_that.action,_that.status,_that.args,_that.createdAt,_that.sentAt,_that.ackedAt,_that.expiresAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  CommandAction action,  CommandStatus status,  Map<String, dynamic> args, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'sent_at')  DateTime? sentAt, @JsonKey(name: 'acked_at')  DateTime? ackedAt, @JsonKey(name: 'expires_at')  DateTime? expiresAt)  $default,) {final _that = this;
switch (_that) {
case _Command():
return $default(_that.id,_that.action,_that.status,_that.args,_that.createdAt,_that.sentAt,_that.ackedAt,_that.expiresAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  CommandAction action,  CommandStatus status,  Map<String, dynamic> args, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'sent_at')  DateTime? sentAt, @JsonKey(name: 'acked_at')  DateTime? ackedAt, @JsonKey(name: 'expires_at')  DateTime? expiresAt)?  $default,) {final _that = this;
switch (_that) {
case _Command() when $default != null:
return $default(_that.id,_that.action,_that.status,_that.args,_that.createdAt,_that.sentAt,_that.ackedAt,_that.expiresAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Command implements Command {
  const _Command({required this.id, required this.action, required this.status,  Map<String, dynamic> args = const <String, dynamic>{}, @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'sent_at') this.sentAt, @JsonKey(name: 'acked_at') this.ackedAt, @JsonKey(name: 'expires_at') this.expiresAt}): _args = args;
  factory _Command.fromJson(Map<String, dynamic> json) => _$CommandFromJson(json);

@override final  String id;
@override final  CommandAction action;
@override final  CommandStatus status;
 final  Map<String, dynamic> _args;
@override@JsonKey() Map<String, dynamic> get args {
  if (_args is EqualUnmodifiableMapView) return _args;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_args);
}

@override@JsonKey(name: 'created_at') final  DateTime? createdAt;
@override@JsonKey(name: 'sent_at') final  DateTime? sentAt;
@override@JsonKey(name: 'acked_at') final  DateTime? ackedAt;
@override@JsonKey(name: 'expires_at') final  DateTime? expiresAt;

/// Create a copy of Command
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommandCopyWith<_Command> get copyWith => __$CommandCopyWithImpl<_Command>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CommandToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Command&&(identical(other.id, id) || other.id == id)&&(identical(other.action, action) || other.action == action)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.args, _args)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.sentAt, sentAt) || other.sentAt == sentAt)&&(identical(other.ackedAt, ackedAt) || other.ackedAt == ackedAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,action,status,const DeepCollectionEquality().hash(_args),createdAt,sentAt,ackedAt,expiresAt);
}

@override
String toString() {
    return 'Command(id: $id, action: $action, status: $status, args: $args, createdAt: $createdAt, sentAt: $sentAt, ackedAt: $ackedAt, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class _$CommandCopyWith<$Res> implements $CommandCopyWith<$Res> {
  factory _$CommandCopyWith(_Command value, $Res Function(_Command) _then) = __$CommandCopyWithImpl;
@override @useResult
$Res call({
 String id, CommandAction action, CommandStatus status, Map<String, dynamic> args,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'sent_at') DateTime? sentAt,@JsonKey(name: 'acked_at') DateTime? ackedAt,@JsonKey(name: 'expires_at') DateTime? expiresAt
});




}
/// @nodoc
class __$CommandCopyWithImpl<$Res>
    implements _$CommandCopyWith<$Res> {
  __$CommandCopyWithImpl(this._self, this._then);

  final _Command _self;
  final $Res Function(_Command) _then;

/// Create a copy of Command
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? action = null,Object? status = null,Object? args = null,Object? createdAt = freezed,Object? sentAt = freezed,Object? ackedAt = freezed,Object? expiresAt = freezed,}) {
  return _then(_Command(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as CommandAction,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CommandStatus,args: null == args ? _self._args : args // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,sentAt: freezed == sentAt ? _self.sentAt : sentAt // ignore: cast_nullable_to_non_nullable
as DateTime?,ackedAt: freezed == ackedAt ? _self.ackedAt : ackedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$CreateCommandResult {

 String get id; CommandAction get action; CommandStatus get status;@JsonKey(name: 'expires_at') DateTime get expiresAt;
/// Create a copy of CreateCommandResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateCommandResultCopyWith<CreateCommandResult> get copyWith => _$CreateCommandResultCopyWithImpl<CreateCommandResult>(this as CreateCommandResult, _$identity);

  /// Serializes this CreateCommandResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CreateCommandResult;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateCommandResult&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.action, _this.action) || other.action == _this.action)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.expiresAt, _this.expiresAt) || other.expiresAt == _this.expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CreateCommandResult;
  return Object.hash(runtimeType,_this.id,_this.action,_this.status,_this.expiresAt);
}

@override
String toString() {
  final _this = this as CreateCommandResult;
  return 'CreateCommandResult(id: ${_this.id}, action: ${_this.action}, status: ${_this.status}, expiresAt: ${_this.expiresAt})';
}


}

/// @nodoc
abstract mixin class $CreateCommandResultCopyWith<$Res>  {
  factory $CreateCommandResultCopyWith(CreateCommandResult value, $Res Function(CreateCommandResult) _then) = _$CreateCommandResultCopyWithImpl;
@useResult
$Res call({
 String id, CommandAction action, CommandStatus status,@JsonKey(name: 'expires_at') DateTime expiresAt
});




}
/// @nodoc
class _$CreateCommandResultCopyWithImpl<$Res>
    implements $CreateCommandResultCopyWith<$Res> {
  _$CreateCommandResultCopyWithImpl(this._self, this._then);

  final CreateCommandResult _self;
  final $Res Function(CreateCommandResult) _then;

/// Create a copy of CreateCommandResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? action = null,Object? status = null,Object? expiresAt = null,}) {
  return _then(CreateCommandResult(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as CommandAction,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CommandStatus,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateCommandResult].
extension CreateCommandResultPatterns on CreateCommandResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateCommandResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateCommandResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateCommandResult value)  $default,){
final _that = this;
switch (_that) {
case _CreateCommandResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateCommandResult value)?  $default,){
final _that = this;
switch (_that) {
case _CreateCommandResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  CommandAction action,  CommandStatus status, @JsonKey(name: 'expires_at')  DateTime expiresAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateCommandResult() when $default != null:
return $default(_that.id,_that.action,_that.status,_that.expiresAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  CommandAction action,  CommandStatus status, @JsonKey(name: 'expires_at')  DateTime expiresAt)  $default,) {final _that = this;
switch (_that) {
case _CreateCommandResult():
return $default(_that.id,_that.action,_that.status,_that.expiresAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  CommandAction action,  CommandStatus status, @JsonKey(name: 'expires_at')  DateTime expiresAt)?  $default,) {final _that = this;
switch (_that) {
case _CreateCommandResult() when $default != null:
return $default(_that.id,_that.action,_that.status,_that.expiresAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateCommandResult implements CreateCommandResult {
  const _CreateCommandResult({required this.id, required this.action, required this.status, @JsonKey(name: 'expires_at') required this.expiresAt});
  factory _CreateCommandResult.fromJson(Map<String, dynamic> json) => _$CreateCommandResultFromJson(json);

@override final  String id;
@override final  CommandAction action;
@override final  CommandStatus status;
@override@JsonKey(name: 'expires_at') final  DateTime expiresAt;

/// Create a copy of CreateCommandResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateCommandResultCopyWith<_CreateCommandResult> get copyWith => __$CreateCommandResultCopyWithImpl<_CreateCommandResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateCommandResultToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateCommandResult&&(identical(other.id, id) || other.id == id)&&(identical(other.action, action) || other.action == action)&&(identical(other.status, status) || other.status == status)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,action,status,expiresAt);
}

@override
String toString() {
    return 'CreateCommandResult(id: $id, action: $action, status: $status, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class _$CreateCommandResultCopyWith<$Res> implements $CreateCommandResultCopyWith<$Res> {
  factory _$CreateCommandResultCopyWith(_CreateCommandResult value, $Res Function(_CreateCommandResult) _then) = __$CreateCommandResultCopyWithImpl;
@override @useResult
$Res call({
 String id, CommandAction action, CommandStatus status,@JsonKey(name: 'expires_at') DateTime expiresAt
});




}
/// @nodoc
class __$CreateCommandResultCopyWithImpl<$Res>
    implements _$CreateCommandResultCopyWith<$Res> {
  __$CreateCommandResultCopyWithImpl(this._self, this._then);

  final _CreateCommandResult _self;
  final $Res Function(_CreateCommandResult) _then;

/// Create a copy of CreateCommandResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? action = null,Object? status = null,Object? expiresAt = null,}) {
  return _then(_CreateCommandResult(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as CommandAction,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CommandStatus,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
