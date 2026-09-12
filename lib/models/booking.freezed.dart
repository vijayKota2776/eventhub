// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'booking.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Booking {

 String get id;@JsonKey(name: 'user_id') String get userId;@JsonKey(name: 'event_id') String get eventId;@JsonKey(name: 'ticket_type_id') String get ticketTypeId; int get quantity;@JsonKey(name: 'unit_price') double get unitPrice;@JsonKey(name: 'total_amount') double get totalAmount; String get status;@JsonKey(name: 'idempotency_key') String get idempotencyKey;@JsonKey(name: 'qr_token') String? get qrToken;@JsonKey(name: 'created_at') DateTime? get createdAt;
/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BookingCopyWith<Booking> get copyWith => _$BookingCopyWithImpl<Booking>(this as Booking, _$identity);

  /// Serializes this Booking to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Booking;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Booking&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&(identical(other.eventId, _this.eventId) || other.eventId == _this.eventId)&&(identical(other.ticketTypeId, _this.ticketTypeId) || other.ticketTypeId == _this.ticketTypeId)&&(identical(other.quantity, _this.quantity) || other.quantity == _this.quantity)&&(identical(other.unitPrice, _this.unitPrice) || other.unitPrice == _this.unitPrice)&&(identical(other.totalAmount, _this.totalAmount) || other.totalAmount == _this.totalAmount)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.idempotencyKey, _this.idempotencyKey) || other.idempotencyKey == _this.idempotencyKey)&&(identical(other.qrToken, _this.qrToken) || other.qrToken == _this.qrToken)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Booking;
  return Object.hash(runtimeType,_this.id,_this.userId,_this.eventId,_this.ticketTypeId,_this.quantity,_this.unitPrice,_this.totalAmount,_this.status,_this.idempotencyKey,_this.qrToken,_this.createdAt);
}

@override
String toString() {
  final _this = this as Booking;
  return 'Booking(id: ${_this.id}, userId: ${_this.userId}, eventId: ${_this.eventId}, ticketTypeId: ${_this.ticketTypeId}, quantity: ${_this.quantity}, unitPrice: ${_this.unitPrice}, totalAmount: ${_this.totalAmount}, status: ${_this.status}, idempotencyKey: ${_this.idempotencyKey}, qrToken: ${_this.qrToken}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $BookingCopyWith<$Res>  {
  factory $BookingCopyWith(Booking value, $Res Function(Booking) _then) = _$BookingCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'event_id') String eventId,@JsonKey(name: 'ticket_type_id') String ticketTypeId, int quantity,@JsonKey(name: 'unit_price') double unitPrice,@JsonKey(name: 'total_amount') double totalAmount, String status,@JsonKey(name: 'idempotency_key') String idempotencyKey,@JsonKey(name: 'qr_token') String? qrToken,@JsonKey(name: 'created_at') DateTime? createdAt
});




}
/// @nodoc
class _$BookingCopyWithImpl<$Res>
    implements $BookingCopyWith<$Res> {
  _$BookingCopyWithImpl(this._self, this._then);

  final Booking _self;
  final $Res Function(Booking) _then;

/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? eventId = null,Object? ticketTypeId = null,Object? quantity = null,Object? unitPrice = null,Object? totalAmount = null,Object? status = null,Object? idempotencyKey = null,Object? qrToken = freezed,Object? createdAt = freezed,}) {
  return _then(Booking(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,ticketTypeId: null == ticketTypeId ? _self.ticketTypeId : ticketTypeId // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,idempotencyKey: null == idempotencyKey ? _self.idempotencyKey : idempotencyKey // ignore: cast_nullable_to_non_nullable
as String,qrToken: freezed == qrToken ? _self.qrToken : qrToken // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Booking].
extension BookingPatterns on Booking {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Booking value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Booking() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Booking value)  $default,){
final _that = this;
switch (_that) {
case _Booking():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Booking value)?  $default,){
final _that = this;
switch (_that) {
case _Booking() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'event_id')  String eventId, @JsonKey(name: 'ticket_type_id')  String ticketTypeId,  int quantity, @JsonKey(name: 'unit_price')  double unitPrice, @JsonKey(name: 'total_amount')  double totalAmount,  String status, @JsonKey(name: 'idempotency_key')  String idempotencyKey, @JsonKey(name: 'qr_token')  String? qrToken, @JsonKey(name: 'created_at')  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Booking() when $default != null:
return $default(_that.id,_that.userId,_that.eventId,_that.ticketTypeId,_that.quantity,_that.unitPrice,_that.totalAmount,_that.status,_that.idempotencyKey,_that.qrToken,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'event_id')  String eventId, @JsonKey(name: 'ticket_type_id')  String ticketTypeId,  int quantity, @JsonKey(name: 'unit_price')  double unitPrice, @JsonKey(name: 'total_amount')  double totalAmount,  String status, @JsonKey(name: 'idempotency_key')  String idempotencyKey, @JsonKey(name: 'qr_token')  String? qrToken, @JsonKey(name: 'created_at')  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _Booking():
return $default(_that.id,_that.userId,_that.eventId,_that.ticketTypeId,_that.quantity,_that.unitPrice,_that.totalAmount,_that.status,_that.idempotencyKey,_that.qrToken,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'event_id')  String eventId, @JsonKey(name: 'ticket_type_id')  String ticketTypeId,  int quantity, @JsonKey(name: 'unit_price')  double unitPrice, @JsonKey(name: 'total_amount')  double totalAmount,  String status, @JsonKey(name: 'idempotency_key')  String idempotencyKey, @JsonKey(name: 'qr_token')  String? qrToken, @JsonKey(name: 'created_at')  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Booking() when $default != null:
return $default(_that.id,_that.userId,_that.eventId,_that.ticketTypeId,_that.quantity,_that.unitPrice,_that.totalAmount,_that.status,_that.idempotencyKey,_that.qrToken,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Booking implements Booking {
  const _Booking({required this.id, @JsonKey(name: 'user_id') required this.userId, @JsonKey(name: 'event_id') required this.eventId, @JsonKey(name: 'ticket_type_id') required this.ticketTypeId, required this.quantity, @JsonKey(name: 'unit_price') required this.unitPrice, @JsonKey(name: 'total_amount') required this.totalAmount, required this.status, @JsonKey(name: 'idempotency_key') required this.idempotencyKey, @JsonKey(name: 'qr_token') this.qrToken, @JsonKey(name: 'created_at') this.createdAt});
  factory _Booking.fromJson(Map<String, dynamic> json) => _$BookingFromJson(json);

@override final  String id;
@override@JsonKey(name: 'user_id') final  String userId;
@override@JsonKey(name: 'event_id') final  String eventId;
@override@JsonKey(name: 'ticket_type_id') final  String ticketTypeId;
@override final  int quantity;
@override@JsonKey(name: 'unit_price') final  double unitPrice;
@override@JsonKey(name: 'total_amount') final  double totalAmount;
@override final  String status;
@override@JsonKey(name: 'idempotency_key') final  String idempotencyKey;
@override@JsonKey(name: 'qr_token') final  String? qrToken;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;

/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BookingCopyWith<_Booking> get copyWith => __$BookingCopyWithImpl<_Booking>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BookingToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Booking&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.ticketTypeId, ticketTypeId) || other.ticketTypeId == ticketTypeId)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.status, status) || other.status == status)&&(identical(other.idempotencyKey, idempotencyKey) || other.idempotencyKey == idempotencyKey)&&(identical(other.qrToken, qrToken) || other.qrToken == qrToken)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,userId,eventId,ticketTypeId,quantity,unitPrice,totalAmount,status,idempotencyKey,qrToken,createdAt);
}

@override
String toString() {
    return 'Booking(id: $id, userId: $userId, eventId: $eventId, ticketTypeId: $ticketTypeId, quantity: $quantity, unitPrice: $unitPrice, totalAmount: $totalAmount, status: $status, idempotencyKey: $idempotencyKey, qrToken: $qrToken, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$BookingCopyWith<$Res> implements $BookingCopyWith<$Res> {
  factory _$BookingCopyWith(_Booking value, $Res Function(_Booking) _then) = __$BookingCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'event_id') String eventId,@JsonKey(name: 'ticket_type_id') String ticketTypeId, int quantity,@JsonKey(name: 'unit_price') double unitPrice,@JsonKey(name: 'total_amount') double totalAmount, String status,@JsonKey(name: 'idempotency_key') String idempotencyKey,@JsonKey(name: 'qr_token') String? qrToken,@JsonKey(name: 'created_at') DateTime? createdAt
});




}
/// @nodoc
class __$BookingCopyWithImpl<$Res>
    implements _$BookingCopyWith<$Res> {
  __$BookingCopyWithImpl(this._self, this._then);

  final _Booking _self;
  final $Res Function(_Booking) _then;

/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? eventId = null,Object? ticketTypeId = null,Object? quantity = null,Object? unitPrice = null,Object? totalAmount = null,Object? status = null,Object? idempotencyKey = null,Object? qrToken = freezed,Object? createdAt = freezed,}) {
  return _then(_Booking(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,ticketTypeId: null == ticketTypeId ? _self.ticketTypeId : ticketTypeId // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,idempotencyKey: null == idempotencyKey ? _self.idempotencyKey : idempotencyKey // ignore: cast_nullable_to_non_nullable
as String,qrToken: freezed == qrToken ? _self.qrToken : qrToken // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
