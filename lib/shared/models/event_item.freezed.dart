// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'event_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EventItem {

 int get id; EventType get type; EventSeverity get severity; String get message; Map<String, dynamic> get payload;@JsonKey(name: 'is_read') bool get isRead;@JsonKey(name: 'created_at') DateTime? get createdAt;
/// Create a copy of EventItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventItemCopyWith<EventItem> get copyWith => _$EventItemCopyWithImpl<EventItem>(this as EventItem, _$identity);

  /// Serializes this EventItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as EventItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventItem&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.severity, _this.severity) || other.severity == _this.severity)&&(identical(other.message, _this.message) || other.message == _this.message)&&const DeepCollectionEquality().equals(other.payload, _this.payload)&&(identical(other.isRead, _this.isRead) || other.isRead == _this.isRead)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as EventItem;
  return Object.hash(runtimeType,_this.id,_this.type,_this.severity,_this.message,const DeepCollectionEquality().hash(_this.payload),_this.isRead,_this.createdAt);
}

@override
String toString() {
  final _this = this as EventItem;
  return 'EventItem(id: ${_this.id}, type: ${_this.type}, severity: ${_this.severity}, message: ${_this.message}, payload: ${_this.payload}, isRead: ${_this.isRead}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $EventItemCopyWith<$Res>  {
  factory $EventItemCopyWith(EventItem value, $Res Function(EventItem) _then) = _$EventItemCopyWithImpl;
@useResult
$Res call({
 int id, EventType type, EventSeverity severity, String message, Map<String, dynamic> payload,@JsonKey(name: 'is_read') bool isRead,@JsonKey(name: 'created_at') DateTime? createdAt
});




}
/// @nodoc
class _$EventItemCopyWithImpl<$Res>
    implements $EventItemCopyWith<$Res> {
  _$EventItemCopyWithImpl(this._self, this._then);

  final EventItem _self;
  final $Res Function(EventItem) _then;

/// Create a copy of EventItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? severity = null,Object? message = null,Object? payload = null,Object? isRead = null,Object? createdAt = freezed,}) {
  return _then(EventItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as EventType,severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as EventSeverity,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,payload: null == payload ? _self.payload : payload // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [EventItem].
extension EventItemPatterns on EventItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EventItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EventItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EventItem value)  $default,){
final _that = this;
switch (_that) {
case _EventItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EventItem value)?  $default,){
final _that = this;
switch (_that) {
case _EventItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  EventType type,  EventSeverity severity,  String message,  Map<String, dynamic> payload, @JsonKey(name: 'is_read')  bool isRead, @JsonKey(name: 'created_at')  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EventItem() when $default != null:
return $default(_that.id,_that.type,_that.severity,_that.message,_that.payload,_that.isRead,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  EventType type,  EventSeverity severity,  String message,  Map<String, dynamic> payload, @JsonKey(name: 'is_read')  bool isRead, @JsonKey(name: 'created_at')  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _EventItem():
return $default(_that.id,_that.type,_that.severity,_that.message,_that.payload,_that.isRead,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  EventType type,  EventSeverity severity,  String message,  Map<String, dynamic> payload, @JsonKey(name: 'is_read')  bool isRead, @JsonKey(name: 'created_at')  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _EventItem() when $default != null:
return $default(_that.id,_that.type,_that.severity,_that.message,_that.payload,_that.isRead,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EventItem implements EventItem {
  const _EventItem({required this.id, required this.type, required this.severity, required this.message,  Map<String, dynamic> payload = const <String, dynamic>{}, @JsonKey(name: 'is_read') required this.isRead, @JsonKey(name: 'created_at') this.createdAt}): _payload = payload;
  factory _EventItem.fromJson(Map<String, dynamic> json) => _$EventItemFromJson(json);

@override final  int id;
@override final  EventType type;
@override final  EventSeverity severity;
@override final  String message;
 final  Map<String, dynamic> _payload;
@override@JsonKey() Map<String, dynamic> get payload {
  if (_payload is EqualUnmodifiableMapView) return _payload;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_payload);
}

@override@JsonKey(name: 'is_read') final  bool isRead;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;

/// Create a copy of EventItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EventItemCopyWith<_EventItem> get copyWith => __$EventItemCopyWithImpl<_EventItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EventItemToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _EventItem&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.severity, severity) || other.severity == severity)&&(identical(other.message, message) || other.message == message)&&const DeepCollectionEquality().equals(other.payload, _payload)&&(identical(other.isRead, isRead) || other.isRead == isRead)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,type,severity,message,const DeepCollectionEquality().hash(_payload),isRead,createdAt);
}

@override
String toString() {
    return 'EventItem(id: $id, type: $type, severity: $severity, message: $message, payload: $payload, isRead: $isRead, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$EventItemCopyWith<$Res> implements $EventItemCopyWith<$Res> {
  factory _$EventItemCopyWith(_EventItem value, $Res Function(_EventItem) _then) = __$EventItemCopyWithImpl;
@override @useResult
$Res call({
 int id, EventType type, EventSeverity severity, String message, Map<String, dynamic> payload,@JsonKey(name: 'is_read') bool isRead,@JsonKey(name: 'created_at') DateTime? createdAt
});




}
/// @nodoc
class __$EventItemCopyWithImpl<$Res>
    implements _$EventItemCopyWith<$Res> {
  __$EventItemCopyWithImpl(this._self, this._then);

  final _EventItem _self;
  final $Res Function(_EventItem) _then;

/// Create a copy of EventItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? severity = null,Object? message = null,Object? payload = null,Object? isRead = null,Object? createdAt = freezed,}) {
  return _then(_EventItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as EventType,severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as EventSeverity,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,payload: null == payload ? _self._payload : payload // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$EventsResponse {

 List<EventItem> get items;@JsonKey(name: 'unread_count') int get unreadCount;
/// Create a copy of EventsResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventsResponseCopyWith<EventsResponse> get copyWith => _$EventsResponseCopyWithImpl<EventsResponse>(this as EventsResponse, _$identity);

  /// Serializes this EventsResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as EventsResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventsResponse&&const DeepCollectionEquality().equals(other.items, _this.items)&&(identical(other.unreadCount, _this.unreadCount) || other.unreadCount == _this.unreadCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as EventsResponse;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.items),_this.unreadCount);
}

@override
String toString() {
  final _this = this as EventsResponse;
  return 'EventsResponse(items: ${_this.items}, unreadCount: ${_this.unreadCount})';
}


}

/// @nodoc
abstract mixin class $EventsResponseCopyWith<$Res>  {
  factory $EventsResponseCopyWith(EventsResponse value, $Res Function(EventsResponse) _then) = _$EventsResponseCopyWithImpl;
@useResult
$Res call({
 List<EventItem> items,@JsonKey(name: 'unread_count') int unreadCount
});




}
/// @nodoc
class _$EventsResponseCopyWithImpl<$Res>
    implements $EventsResponseCopyWith<$Res> {
  _$EventsResponseCopyWithImpl(this._self, this._then);

  final EventsResponse _self;
  final $Res Function(EventsResponse) _then;

/// Create a copy of EventsResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? unreadCount = null,}) {
  return _then(EventsResponse(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<EventItem>,unreadCount: null == unreadCount ? _self.unreadCount : unreadCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [EventsResponse].
extension EventsResponsePatterns on EventsResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EventsResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EventsResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EventsResponse value)  $default,){
final _that = this;
switch (_that) {
case _EventsResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EventsResponse value)?  $default,){
final _that = this;
switch (_that) {
case _EventsResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<EventItem> items, @JsonKey(name: 'unread_count')  int unreadCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EventsResponse() when $default != null:
return $default(_that.items,_that.unreadCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<EventItem> items, @JsonKey(name: 'unread_count')  int unreadCount)  $default,) {final _that = this;
switch (_that) {
case _EventsResponse():
return $default(_that.items,_that.unreadCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<EventItem> items, @JsonKey(name: 'unread_count')  int unreadCount)?  $default,) {final _that = this;
switch (_that) {
case _EventsResponse() when $default != null:
return $default(_that.items,_that.unreadCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EventsResponse implements EventsResponse {
  const _EventsResponse({ List<EventItem> items = const <EventItem>[], @JsonKey(name: 'unread_count') this.unreadCount = 0}): _items = items;
  factory _EventsResponse.fromJson(Map<String, dynamic> json) => _$EventsResponseFromJson(json);

 final  List<EventItem> _items;
@override@JsonKey() List<EventItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override@JsonKey(name: 'unread_count') final  int unreadCount;

/// Create a copy of EventsResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EventsResponseCopyWith<_EventsResponse> get copyWith => __$EventsResponseCopyWithImpl<_EventsResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EventsResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _EventsResponse&&const DeepCollectionEquality().equals(other.items, _items)&&(identical(other.unreadCount, unreadCount) || other.unreadCount == unreadCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),unreadCount);
}

@override
String toString() {
    return 'EventsResponse(items: $items, unreadCount: $unreadCount)';
}


}

/// @nodoc
abstract mixin class _$EventsResponseCopyWith<$Res> implements $EventsResponseCopyWith<$Res> {
  factory _$EventsResponseCopyWith(_EventsResponse value, $Res Function(_EventsResponse) _then) = __$EventsResponseCopyWithImpl;
@override @useResult
$Res call({
 List<EventItem> items,@JsonKey(name: 'unread_count') int unreadCount
});




}
/// @nodoc
class __$EventsResponseCopyWithImpl<$Res>
    implements _$EventsResponseCopyWith<$Res> {
  __$EventsResponseCopyWithImpl(this._self, this._then);

  final _EventsResponse _self;
  final $Res Function(_EventsResponse) _then;

/// Create a copy of EventsResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? unreadCount = null,}) {
  return _then(_EventsResponse(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<EventItem>,unreadCount: null == unreadCount ? _self.unreadCount : unreadCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
