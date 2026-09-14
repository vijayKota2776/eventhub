// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'event_stats.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EventStats {

 String get id; String get title;@JsonKey(name: 'tickets_sold') int get ticketsSold; num get revenue; int get attended;@JsonKey(name: 'attendance_rate') num get attendanceRate;
/// Create a copy of EventStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventStatsCopyWith<EventStats> get copyWith => _$EventStatsCopyWithImpl<EventStats>(this as EventStats, _$identity);

  /// Serializes this EventStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as EventStats;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventStats&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.ticketsSold, _this.ticketsSold) || other.ticketsSold == _this.ticketsSold)&&(identical(other.revenue, _this.revenue) || other.revenue == _this.revenue)&&(identical(other.attended, _this.attended) || other.attended == _this.attended)&&(identical(other.attendanceRate, _this.attendanceRate) || other.attendanceRate == _this.attendanceRate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as EventStats;
  return Object.hash(runtimeType,_this.id,_this.title,_this.ticketsSold,_this.revenue,_this.attended,_this.attendanceRate);
}

@override
String toString() {
  final _this = this as EventStats;
  return 'EventStats(id: ${_this.id}, title: ${_this.title}, ticketsSold: ${_this.ticketsSold}, revenue: ${_this.revenue}, attended: ${_this.attended}, attendanceRate: ${_this.attendanceRate})';
}


}

/// @nodoc
abstract mixin class $EventStatsCopyWith<$Res>  {
  factory $EventStatsCopyWith(EventStats value, $Res Function(EventStats) _then) = _$EventStatsCopyWithImpl;
@useResult
$Res call({
 String id, String title,@JsonKey(name: 'tickets_sold') int ticketsSold, num revenue, int attended,@JsonKey(name: 'attendance_rate') num attendanceRate
});




}
/// @nodoc
class _$EventStatsCopyWithImpl<$Res>
    implements $EventStatsCopyWith<$Res> {
  _$EventStatsCopyWithImpl(this._self, this._then);

  final EventStats _self;
  final $Res Function(EventStats) _then;

/// Create a copy of EventStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? ticketsSold = null,Object? revenue = null,Object? attended = null,Object? attendanceRate = null,}) {
  return _then(EventStats(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,ticketsSold: null == ticketsSold ? _self.ticketsSold : ticketsSold // ignore: cast_nullable_to_non_nullable
as int,revenue: null == revenue ? _self.revenue : revenue // ignore: cast_nullable_to_non_nullable
as num,attended: null == attended ? _self.attended : attended // ignore: cast_nullable_to_non_nullable
as int,attendanceRate: null == attendanceRate ? _self.attendanceRate : attendanceRate // ignore: cast_nullable_to_non_nullable
as num,
  ));
}

}


/// Adds pattern-matching-related methods to [EventStats].
extension EventStatsPatterns on EventStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EventStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EventStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EventStats value)  $default,){
final _that = this;
switch (_that) {
case _EventStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EventStats value)?  $default,){
final _that = this;
switch (_that) {
case _EventStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title, @JsonKey(name: 'tickets_sold')  int ticketsSold,  num revenue,  int attended, @JsonKey(name: 'attendance_rate')  num attendanceRate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EventStats() when $default != null:
return $default(_that.id,_that.title,_that.ticketsSold,_that.revenue,_that.attended,_that.attendanceRate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title, @JsonKey(name: 'tickets_sold')  int ticketsSold,  num revenue,  int attended, @JsonKey(name: 'attendance_rate')  num attendanceRate)  $default,) {final _that = this;
switch (_that) {
case _EventStats():
return $default(_that.id,_that.title,_that.ticketsSold,_that.revenue,_that.attended,_that.attendanceRate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title, @JsonKey(name: 'tickets_sold')  int ticketsSold,  num revenue,  int attended, @JsonKey(name: 'attendance_rate')  num attendanceRate)?  $default,) {final _that = this;
switch (_that) {
case _EventStats() when $default != null:
return $default(_that.id,_that.title,_that.ticketsSold,_that.revenue,_that.attended,_that.attendanceRate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EventStats implements EventStats {
  const _EventStats({required this.id, required this.title, @JsonKey(name: 'tickets_sold') this.ticketsSold = 0, this.revenue = 0, this.attended = 0, @JsonKey(name: 'attendance_rate') this.attendanceRate = 0});
  factory _EventStats.fromJson(Map<String, dynamic> json) => _$EventStatsFromJson(json);

@override final  String id;
@override final  String title;
@override@JsonKey(name: 'tickets_sold') final  int ticketsSold;
@override@JsonKey() final  num revenue;
@override@JsonKey() final  int attended;
@override@JsonKey(name: 'attendance_rate') final  num attendanceRate;

/// Create a copy of EventStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EventStatsCopyWith<_EventStats> get copyWith => __$EventStatsCopyWithImpl<_EventStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EventStatsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _EventStats&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.ticketsSold, ticketsSold) || other.ticketsSold == ticketsSold)&&(identical(other.revenue, revenue) || other.revenue == revenue)&&(identical(other.attended, attended) || other.attended == attended)&&(identical(other.attendanceRate, attendanceRate) || other.attendanceRate == attendanceRate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,title,ticketsSold,revenue,attended,attendanceRate);
}

@override
String toString() {
    return 'EventStats(id: $id, title: $title, ticketsSold: $ticketsSold, revenue: $revenue, attended: $attended, attendanceRate: $attendanceRate)';
}


}

/// @nodoc
abstract mixin class _$EventStatsCopyWith<$Res> implements $EventStatsCopyWith<$Res> {
  factory _$EventStatsCopyWith(_EventStats value, $Res Function(_EventStats) _then) = __$EventStatsCopyWithImpl;
@override @useResult
$Res call({
 String id, String title,@JsonKey(name: 'tickets_sold') int ticketsSold, num revenue, int attended,@JsonKey(name: 'attendance_rate') num attendanceRate
});




}
/// @nodoc
class __$EventStatsCopyWithImpl<$Res>
    implements _$EventStatsCopyWith<$Res> {
  __$EventStatsCopyWithImpl(this._self, this._then);

  final _EventStats _self;
  final $Res Function(_EventStats) _then;

/// Create a copy of EventStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? ticketsSold = null,Object? revenue = null,Object? attended = null,Object? attendanceRate = null,}) {
  return _then(_EventStats(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,ticketsSold: null == ticketsSold ? _self.ticketsSold : ticketsSold // ignore: cast_nullable_to_non_nullable
as int,revenue: null == revenue ? _self.revenue : revenue // ignore: cast_nullable_to_non_nullable
as num,attended: null == attended ? _self.attended : attended // ignore: cast_nullable_to_non_nullable
as int,attendanceRate: null == attendanceRate ? _self.attendanceRate : attendanceRate // ignore: cast_nullable_to_non_nullable
as num,
  ));
}


}

// dart format on
