// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ticket_type.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TicketType {

 String get id;@JsonKey(name: 'event_id') String get eventId; String get name; double get price;@JsonKey(name: 'quantity_total') int get quantityTotal;@JsonKey(name: 'quantity_sold') int get quantitySold;@JsonKey(name: 'sales_start') DateTime get salesStart;@JsonKey(name: 'sales_end') DateTime get salesEnd;
/// Create a copy of TicketType
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TicketTypeCopyWith<TicketType> get copyWith => _$TicketTypeCopyWithImpl<TicketType>(this as TicketType, _$identity);

  /// Serializes this TicketType to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TicketType;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TicketType&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.eventId, _this.eventId) || other.eventId == _this.eventId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.price, _this.price) || other.price == _this.price)&&(identical(other.quantityTotal, _this.quantityTotal) || other.quantityTotal == _this.quantityTotal)&&(identical(other.quantitySold, _this.quantitySold) || other.quantitySold == _this.quantitySold)&&(identical(other.salesStart, _this.salesStart) || other.salesStart == _this.salesStart)&&(identical(other.salesEnd, _this.salesEnd) || other.salesEnd == _this.salesEnd));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TicketType;
  return Object.hash(runtimeType,_this.id,_this.eventId,_this.name,_this.price,_this.quantityTotal,_this.quantitySold,_this.salesStart,_this.salesEnd);
}

@override
String toString() {
  final _this = this as TicketType;
  return 'TicketType(id: ${_this.id}, eventId: ${_this.eventId}, name: ${_this.name}, price: ${_this.price}, quantityTotal: ${_this.quantityTotal}, quantitySold: ${_this.quantitySold}, salesStart: ${_this.salesStart}, salesEnd: ${_this.salesEnd})';
}


}

/// @nodoc
abstract mixin class $TicketTypeCopyWith<$Res>  {
  factory $TicketTypeCopyWith(TicketType value, $Res Function(TicketType) _then) = _$TicketTypeCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'event_id') String eventId, String name, double price,@JsonKey(name: 'quantity_total') int quantityTotal,@JsonKey(name: 'quantity_sold') int quantitySold,@JsonKey(name: 'sales_start') DateTime salesStart,@JsonKey(name: 'sales_end') DateTime salesEnd
});




}
/// @nodoc
class _$TicketTypeCopyWithImpl<$Res>
    implements $TicketTypeCopyWith<$Res> {
  _$TicketTypeCopyWithImpl(this._self, this._then);

  final TicketType _self;
  final $Res Function(TicketType) _then;

/// Create a copy of TicketType
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? eventId = null,Object? name = null,Object? price = null,Object? quantityTotal = null,Object? quantitySold = null,Object? salesStart = null,Object? salesEnd = null,}) {
  return _then(TicketType(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,quantityTotal: null == quantityTotal ? _self.quantityTotal : quantityTotal // ignore: cast_nullable_to_non_nullable
as int,quantitySold: null == quantitySold ? _self.quantitySold : quantitySold // ignore: cast_nullable_to_non_nullable
as int,salesStart: null == salesStart ? _self.salesStart : salesStart // ignore: cast_nullable_to_non_nullable
as DateTime,salesEnd: null == salesEnd ? _self.salesEnd : salesEnd // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [TicketType].
extension TicketTypePatterns on TicketType {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TicketType value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TicketType() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TicketType value)  $default,){
final _that = this;
switch (_that) {
case _TicketType():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TicketType value)?  $default,){
final _that = this;
switch (_that) {
case _TicketType() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'event_id')  String eventId,  String name,  double price, @JsonKey(name: 'quantity_total')  int quantityTotal, @JsonKey(name: 'quantity_sold')  int quantitySold, @JsonKey(name: 'sales_start')  DateTime salesStart, @JsonKey(name: 'sales_end')  DateTime salesEnd)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TicketType() when $default != null:
return $default(_that.id,_that.eventId,_that.name,_that.price,_that.quantityTotal,_that.quantitySold,_that.salesStart,_that.salesEnd);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'event_id')  String eventId,  String name,  double price, @JsonKey(name: 'quantity_total')  int quantityTotal, @JsonKey(name: 'quantity_sold')  int quantitySold, @JsonKey(name: 'sales_start')  DateTime salesStart, @JsonKey(name: 'sales_end')  DateTime salesEnd)  $default,) {final _that = this;
switch (_that) {
case _TicketType():
return $default(_that.id,_that.eventId,_that.name,_that.price,_that.quantityTotal,_that.quantitySold,_that.salesStart,_that.salesEnd);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'event_id')  String eventId,  String name,  double price, @JsonKey(name: 'quantity_total')  int quantityTotal, @JsonKey(name: 'quantity_sold')  int quantitySold, @JsonKey(name: 'sales_start')  DateTime salesStart, @JsonKey(name: 'sales_end')  DateTime salesEnd)?  $default,) {final _that = this;
switch (_that) {
case _TicketType() when $default != null:
return $default(_that.id,_that.eventId,_that.name,_that.price,_that.quantityTotal,_that.quantitySold,_that.salesStart,_that.salesEnd);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TicketType implements TicketType {
  const _TicketType({required this.id, @JsonKey(name: 'event_id') required this.eventId, required this.name, required this.price, @JsonKey(name: 'quantity_total') required this.quantityTotal, @JsonKey(name: 'quantity_sold') this.quantitySold = 0, @JsonKey(name: 'sales_start') required this.salesStart, @JsonKey(name: 'sales_end') required this.salesEnd});
  factory _TicketType.fromJson(Map<String, dynamic> json) => _$TicketTypeFromJson(json);

@override final  String id;
@override@JsonKey(name: 'event_id') final  String eventId;
@override final  String name;
@override final  double price;
@override@JsonKey(name: 'quantity_total') final  int quantityTotal;
@override@JsonKey(name: 'quantity_sold') final  int quantitySold;
@override@JsonKey(name: 'sales_start') final  DateTime salesStart;
@override@JsonKey(name: 'sales_end') final  DateTime salesEnd;

/// Create a copy of TicketType
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TicketTypeCopyWith<_TicketType> get copyWith => __$TicketTypeCopyWithImpl<_TicketType>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TicketTypeToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TicketType&&(identical(other.id, id) || other.id == id)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.name, name) || other.name == name)&&(identical(other.price, price) || other.price == price)&&(identical(other.quantityTotal, quantityTotal) || other.quantityTotal == quantityTotal)&&(identical(other.quantitySold, quantitySold) || other.quantitySold == quantitySold)&&(identical(other.salesStart, salesStart) || other.salesStart == salesStart)&&(identical(other.salesEnd, salesEnd) || other.salesEnd == salesEnd));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,eventId,name,price,quantityTotal,quantitySold,salesStart,salesEnd);
}

@override
String toString() {
    return 'TicketType(id: $id, eventId: $eventId, name: $name, price: $price, quantityTotal: $quantityTotal, quantitySold: $quantitySold, salesStart: $salesStart, salesEnd: $salesEnd)';
}


}

/// @nodoc
abstract mixin class _$TicketTypeCopyWith<$Res> implements $TicketTypeCopyWith<$Res> {
  factory _$TicketTypeCopyWith(_TicketType value, $Res Function(_TicketType) _then) = __$TicketTypeCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'event_id') String eventId, String name, double price,@JsonKey(name: 'quantity_total') int quantityTotal,@JsonKey(name: 'quantity_sold') int quantitySold,@JsonKey(name: 'sales_start') DateTime salesStart,@JsonKey(name: 'sales_end') DateTime salesEnd
});




}
/// @nodoc
class __$TicketTypeCopyWithImpl<$Res>
    implements _$TicketTypeCopyWith<$Res> {
  __$TicketTypeCopyWithImpl(this._self, this._then);

  final _TicketType _self;
  final $Res Function(_TicketType) _then;

/// Create a copy of TicketType
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? eventId = null,Object? name = null,Object? price = null,Object? quantityTotal = null,Object? quantitySold = null,Object? salesStart = null,Object? salesEnd = null,}) {
  return _then(_TicketType(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,quantityTotal: null == quantityTotal ? _self.quantityTotal : quantityTotal // ignore: cast_nullable_to_non_nullable
as int,quantitySold: null == quantitySold ? _self.quantitySold : quantitySold // ignore: cast_nullable_to_non_nullable
as int,salesStart: null == salesStart ? _self.salesStart : salesStart // ignore: cast_nullable_to_non_nullable
as DateTime,salesEnd: null == salesEnd ? _self.salesEnd : salesEnd // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
