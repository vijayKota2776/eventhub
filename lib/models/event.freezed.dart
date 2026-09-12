// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Event {

 String get id;@JsonKey(name: 'organizer_id') String get organizerId; String get title; String? get description; String get venue; String get city;@JsonKey(name: 'start_at') DateTime get startAt;@JsonKey(name: 'end_at') DateTime get endAt;@JsonKey(name: 'banner_url') String? get bannerUrl; String get category; String get status;@JsonKey(name: 'total_sold') int get totalSold;@JsonKey(name: 'gross_revenue') num get grossRevenue;@JsonKey(name: 'created_at') DateTime? get createdAt;
/// Create a copy of Event
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventCopyWith<Event> get copyWith => _$EventCopyWithImpl<Event>(this as Event, _$identity);

  /// Serializes this Event to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Event;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Event&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.organizerId, _this.organizerId) || other.organizerId == _this.organizerId)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.venue, _this.venue) || other.venue == _this.venue)&&(identical(other.city, _this.city) || other.city == _this.city)&&(identical(other.startAt, _this.startAt) || other.startAt == _this.startAt)&&(identical(other.endAt, _this.endAt) || other.endAt == _this.endAt)&&(identical(other.bannerUrl, _this.bannerUrl) || other.bannerUrl == _this.bannerUrl)&&(identical(other.category, _this.category) || other.category == _this.category)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.totalSold, _this.totalSold) || other.totalSold == _this.totalSold)&&(identical(other.grossRevenue, _this.grossRevenue) || other.grossRevenue == _this.grossRevenue)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Event;
  return Object.hash(runtimeType,_this.id,_this.organizerId,_this.title,_this.description,_this.venue,_this.city,_this.startAt,_this.endAt,_this.bannerUrl,_this.category,_this.status,_this.totalSold,_this.grossRevenue,_this.createdAt);
}

@override
String toString() {
  final _this = this as Event;
  return 'Event(id: ${_this.id}, organizerId: ${_this.organizerId}, title: ${_this.title}, description: ${_this.description}, venue: ${_this.venue}, city: ${_this.city}, startAt: ${_this.startAt}, endAt: ${_this.endAt}, bannerUrl: ${_this.bannerUrl}, category: ${_this.category}, status: ${_this.status}, totalSold: ${_this.totalSold}, grossRevenue: ${_this.grossRevenue}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $EventCopyWith<$Res>  {
  factory $EventCopyWith(Event value, $Res Function(Event) _then) = _$EventCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'organizer_id') String organizerId, String title, String? description, String venue, String city,@JsonKey(name: 'start_at') DateTime startAt,@JsonKey(name: 'end_at') DateTime endAt,@JsonKey(name: 'banner_url') String? bannerUrl, String category, String status,@JsonKey(name: 'total_sold') int totalSold,@JsonKey(name: 'gross_revenue') num grossRevenue,@JsonKey(name: 'created_at') DateTime? createdAt
});




}
/// @nodoc
class _$EventCopyWithImpl<$Res>
    implements $EventCopyWith<$Res> {
  _$EventCopyWithImpl(this._self, this._then);

  final Event _self;
  final $Res Function(Event) _then;

/// Create a copy of Event
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? organizerId = null,Object? title = null,Object? description = freezed,Object? venue = null,Object? city = null,Object? startAt = null,Object? endAt = null,Object? bannerUrl = freezed,Object? category = null,Object? status = null,Object? totalSold = null,Object? grossRevenue = null,Object? createdAt = freezed,}) {
  return _then(Event(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizerId: null == organizerId ? _self.organizerId : organizerId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,venue: null == venue ? _self.venue : venue // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,startAt: null == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as DateTime,endAt: null == endAt ? _self.endAt : endAt // ignore: cast_nullable_to_non_nullable
as DateTime,bannerUrl: freezed == bannerUrl ? _self.bannerUrl : bannerUrl // ignore: cast_nullable_to_non_nullable
as String?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,totalSold: null == totalSold ? _self.totalSold : totalSold // ignore: cast_nullable_to_non_nullable
as int,grossRevenue: null == grossRevenue ? _self.grossRevenue : grossRevenue // ignore: cast_nullable_to_non_nullable
as num,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Event].
extension EventPatterns on Event {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Event value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Event() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Event value)  $default,){
final _that = this;
switch (_that) {
case _Event():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Event value)?  $default,){
final _that = this;
switch (_that) {
case _Event() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'organizer_id')  String organizerId,  String title,  String? description,  String venue,  String city, @JsonKey(name: 'start_at')  DateTime startAt, @JsonKey(name: 'end_at')  DateTime endAt, @JsonKey(name: 'banner_url')  String? bannerUrl,  String category,  String status, @JsonKey(name: 'total_sold')  int totalSold, @JsonKey(name: 'gross_revenue')  num grossRevenue, @JsonKey(name: 'created_at')  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Event() when $default != null:
return $default(_that.id,_that.organizerId,_that.title,_that.description,_that.venue,_that.city,_that.startAt,_that.endAt,_that.bannerUrl,_that.category,_that.status,_that.totalSold,_that.grossRevenue,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'organizer_id')  String organizerId,  String title,  String? description,  String venue,  String city, @JsonKey(name: 'start_at')  DateTime startAt, @JsonKey(name: 'end_at')  DateTime endAt, @JsonKey(name: 'banner_url')  String? bannerUrl,  String category,  String status, @JsonKey(name: 'total_sold')  int totalSold, @JsonKey(name: 'gross_revenue')  num grossRevenue, @JsonKey(name: 'created_at')  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _Event():
return $default(_that.id,_that.organizerId,_that.title,_that.description,_that.venue,_that.city,_that.startAt,_that.endAt,_that.bannerUrl,_that.category,_that.status,_that.totalSold,_that.grossRevenue,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'organizer_id')  String organizerId,  String title,  String? description,  String venue,  String city, @JsonKey(name: 'start_at')  DateTime startAt, @JsonKey(name: 'end_at')  DateTime endAt, @JsonKey(name: 'banner_url')  String? bannerUrl,  String category,  String status, @JsonKey(name: 'total_sold')  int totalSold, @JsonKey(name: 'gross_revenue')  num grossRevenue, @JsonKey(name: 'created_at')  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Event() when $default != null:
return $default(_that.id,_that.organizerId,_that.title,_that.description,_that.venue,_that.city,_that.startAt,_that.endAt,_that.bannerUrl,_that.category,_that.status,_that.totalSold,_that.grossRevenue,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Event implements Event {
  const _Event({required this.id, @JsonKey(name: 'organizer_id') required this.organizerId, required this.title, this.description, required this.venue, required this.city, @JsonKey(name: 'start_at') required this.startAt, @JsonKey(name: 'end_at') required this.endAt, @JsonKey(name: 'banner_url') this.bannerUrl, required this.category, this.status = 'draft', @JsonKey(name: 'total_sold') this.totalSold = 0, @JsonKey(name: 'gross_revenue') this.grossRevenue = 0, @JsonKey(name: 'created_at') this.createdAt});
  factory _Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);

@override final  String id;
@override@JsonKey(name: 'organizer_id') final  String organizerId;
@override final  String title;
@override final  String? description;
@override final  String venue;
@override final  String city;
@override@JsonKey(name: 'start_at') final  DateTime startAt;
@override@JsonKey(name: 'end_at') final  DateTime endAt;
@override@JsonKey(name: 'banner_url') final  String? bannerUrl;
@override final  String category;
@override@JsonKey() final  String status;
@override@JsonKey(name: 'total_sold') final  int totalSold;
@override@JsonKey(name: 'gross_revenue') final  num grossRevenue;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;

/// Create a copy of Event
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EventCopyWith<_Event> get copyWith => __$EventCopyWithImpl<_Event>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EventToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Event&&(identical(other.id, id) || other.id == id)&&(identical(other.organizerId, organizerId) || other.organizerId == organizerId)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.venue, venue) || other.venue == venue)&&(identical(other.city, city) || other.city == city)&&(identical(other.startAt, startAt) || other.startAt == startAt)&&(identical(other.endAt, endAt) || other.endAt == endAt)&&(identical(other.bannerUrl, bannerUrl) || other.bannerUrl == bannerUrl)&&(identical(other.category, category) || other.category == category)&&(identical(other.status, status) || other.status == status)&&(identical(other.totalSold, totalSold) || other.totalSold == totalSold)&&(identical(other.grossRevenue, grossRevenue) || other.grossRevenue == grossRevenue)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,organizerId,title,description,venue,city,startAt,endAt,bannerUrl,category,status,totalSold,grossRevenue,createdAt);
}

@override
String toString() {
    return 'Event(id: $id, organizerId: $organizerId, title: $title, description: $description, venue: $venue, city: $city, startAt: $startAt, endAt: $endAt, bannerUrl: $bannerUrl, category: $category, status: $status, totalSold: $totalSold, grossRevenue: $grossRevenue, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$EventCopyWith<$Res> implements $EventCopyWith<$Res> {
  factory _$EventCopyWith(_Event value, $Res Function(_Event) _then) = __$EventCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'organizer_id') String organizerId, String title, String? description, String venue, String city,@JsonKey(name: 'start_at') DateTime startAt,@JsonKey(name: 'end_at') DateTime endAt,@JsonKey(name: 'banner_url') String? bannerUrl, String category, String status,@JsonKey(name: 'total_sold') int totalSold,@JsonKey(name: 'gross_revenue') num grossRevenue,@JsonKey(name: 'created_at') DateTime? createdAt
});




}
/// @nodoc
class __$EventCopyWithImpl<$Res>
    implements _$EventCopyWith<$Res> {
  __$EventCopyWithImpl(this._self, this._then);

  final _Event _self;
  final $Res Function(_Event) _then;

/// Create a copy of Event
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? organizerId = null,Object? title = null,Object? description = freezed,Object? venue = null,Object? city = null,Object? startAt = null,Object? endAt = null,Object? bannerUrl = freezed,Object? category = null,Object? status = null,Object? totalSold = null,Object? grossRevenue = null,Object? createdAt = freezed,}) {
  return _then(_Event(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizerId: null == organizerId ? _self.organizerId : organizerId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,venue: null == venue ? _self.venue : venue // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,startAt: null == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as DateTime,endAt: null == endAt ? _self.endAt : endAt // ignore: cast_nullable_to_non_nullable
as DateTime,bannerUrl: freezed == bannerUrl ? _self.bannerUrl : bannerUrl // ignore: cast_nullable_to_non_nullable
as String?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,totalSold: null == totalSold ? _self.totalSold : totalSold // ignore: cast_nullable_to_non_nullable
as int,grossRevenue: null == grossRevenue ? _self.grossRevenue : grossRevenue // ignore: cast_nullable_to_non_nullable
as num,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
