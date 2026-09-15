// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'promo_code.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PromoCode {

 String get id;@JsonKey(name: 'event_id') String get eventId; String get code;@JsonKey(name: 'discount_amount') double? get discountAmount;@JsonKey(name: 'discount_percent') double? get discountPercent;@JsonKey(name: 'max_uses') int? get maxUses; int get uses;@JsonKey(name: 'valid_until') DateTime? get validUntil;
/// Create a copy of PromoCode
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PromoCodeCopyWith<PromoCode> get copyWith => _$PromoCodeCopyWithImpl<PromoCode>(this as PromoCode, _$identity);

  /// Serializes this PromoCode to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PromoCode;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PromoCode&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.eventId, _this.eventId) || other.eventId == _this.eventId)&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.discountAmount, _this.discountAmount) || other.discountAmount == _this.discountAmount)&&(identical(other.discountPercent, _this.discountPercent) || other.discountPercent == _this.discountPercent)&&(identical(other.maxUses, _this.maxUses) || other.maxUses == _this.maxUses)&&(identical(other.uses, _this.uses) || other.uses == _this.uses)&&(identical(other.validUntil, _this.validUntil) || other.validUntil == _this.validUntil));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PromoCode;
  return Object.hash(runtimeType,_this.id,_this.eventId,_this.code,_this.discountAmount,_this.discountPercent,_this.maxUses,_this.uses,_this.validUntil);
}

@override
String toString() {
  final _this = this as PromoCode;
  return 'PromoCode(id: ${_this.id}, eventId: ${_this.eventId}, code: ${_this.code}, discountAmount: ${_this.discountAmount}, discountPercent: ${_this.discountPercent}, maxUses: ${_this.maxUses}, uses: ${_this.uses}, validUntil: ${_this.validUntil})';
}


}

/// @nodoc
abstract mixin class $PromoCodeCopyWith<$Res>  {
  factory $PromoCodeCopyWith(PromoCode value, $Res Function(PromoCode) _then) = _$PromoCodeCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'event_id') String eventId, String code,@JsonKey(name: 'discount_amount') double? discountAmount,@JsonKey(name: 'discount_percent') double? discountPercent,@JsonKey(name: 'max_uses') int? maxUses, int uses,@JsonKey(name: 'valid_until') DateTime? validUntil
});




}
/// @nodoc
class _$PromoCodeCopyWithImpl<$Res>
    implements $PromoCodeCopyWith<$Res> {
  _$PromoCodeCopyWithImpl(this._self, this._then);

  final PromoCode _self;
  final $Res Function(PromoCode) _then;

/// Create a copy of PromoCode
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? eventId = null,Object? code = null,Object? discountAmount = freezed,Object? discountPercent = freezed,Object? maxUses = freezed,Object? uses = null,Object? validUntil = freezed,}) {
  return _then(PromoCode(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,discountAmount: freezed == discountAmount ? _self.discountAmount : discountAmount // ignore: cast_nullable_to_non_nullable
as double?,discountPercent: freezed == discountPercent ? _self.discountPercent : discountPercent // ignore: cast_nullable_to_non_nullable
as double?,maxUses: freezed == maxUses ? _self.maxUses : maxUses // ignore: cast_nullable_to_non_nullable
as int?,uses: null == uses ? _self.uses : uses // ignore: cast_nullable_to_non_nullable
as int,validUntil: freezed == validUntil ? _self.validUntil : validUntil // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [PromoCode].
extension PromoCodePatterns on PromoCode {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PromoCode value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PromoCode() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PromoCode value)  $default,){
final _that = this;
switch (_that) {
case _PromoCode():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PromoCode value)?  $default,){
final _that = this;
switch (_that) {
case _PromoCode() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'event_id')  String eventId,  String code, @JsonKey(name: 'discount_amount')  double? discountAmount, @JsonKey(name: 'discount_percent')  double? discountPercent, @JsonKey(name: 'max_uses')  int? maxUses,  int uses, @JsonKey(name: 'valid_until')  DateTime? validUntil)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PromoCode() when $default != null:
return $default(_that.id,_that.eventId,_that.code,_that.discountAmount,_that.discountPercent,_that.maxUses,_that.uses,_that.validUntil);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'event_id')  String eventId,  String code, @JsonKey(name: 'discount_amount')  double? discountAmount, @JsonKey(name: 'discount_percent')  double? discountPercent, @JsonKey(name: 'max_uses')  int? maxUses,  int uses, @JsonKey(name: 'valid_until')  DateTime? validUntil)  $default,) {final _that = this;
switch (_that) {
case _PromoCode():
return $default(_that.id,_that.eventId,_that.code,_that.discountAmount,_that.discountPercent,_that.maxUses,_that.uses,_that.validUntil);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'event_id')  String eventId,  String code, @JsonKey(name: 'discount_amount')  double? discountAmount, @JsonKey(name: 'discount_percent')  double? discountPercent, @JsonKey(name: 'max_uses')  int? maxUses,  int uses, @JsonKey(name: 'valid_until')  DateTime? validUntil)?  $default,) {final _that = this;
switch (_that) {
case _PromoCode() when $default != null:
return $default(_that.id,_that.eventId,_that.code,_that.discountAmount,_that.discountPercent,_that.maxUses,_that.uses,_that.validUntil);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PromoCode implements PromoCode {
  const _PromoCode({required this.id, @JsonKey(name: 'event_id') required this.eventId, required this.code, @JsonKey(name: 'discount_amount') this.discountAmount, @JsonKey(name: 'discount_percent') this.discountPercent, @JsonKey(name: 'max_uses') this.maxUses, this.uses = 0, @JsonKey(name: 'valid_until') this.validUntil});
  factory _PromoCode.fromJson(Map<String, dynamic> json) => _$PromoCodeFromJson(json);

@override final  String id;
@override@JsonKey(name: 'event_id') final  String eventId;
@override final  String code;
@override@JsonKey(name: 'discount_amount') final  double? discountAmount;
@override@JsonKey(name: 'discount_percent') final  double? discountPercent;
@override@JsonKey(name: 'max_uses') final  int? maxUses;
@override@JsonKey() final  int uses;
@override@JsonKey(name: 'valid_until') final  DateTime? validUntil;

/// Create a copy of PromoCode
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PromoCodeCopyWith<_PromoCode> get copyWith => __$PromoCodeCopyWithImpl<_PromoCode>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PromoCodeToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PromoCode&&(identical(other.id, id) || other.id == id)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.code, code) || other.code == code)&&(identical(other.discountAmount, discountAmount) || other.discountAmount == discountAmount)&&(identical(other.discountPercent, discountPercent) || other.discountPercent == discountPercent)&&(identical(other.maxUses, maxUses) || other.maxUses == maxUses)&&(identical(other.uses, uses) || other.uses == uses)&&(identical(other.validUntil, validUntil) || other.validUntil == validUntil));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,eventId,code,discountAmount,discountPercent,maxUses,uses,validUntil);
}

@override
String toString() {
    return 'PromoCode(id: $id, eventId: $eventId, code: $code, discountAmount: $discountAmount, discountPercent: $discountPercent, maxUses: $maxUses, uses: $uses, validUntil: $validUntil)';
}


}

/// @nodoc
abstract mixin class _$PromoCodeCopyWith<$Res> implements $PromoCodeCopyWith<$Res> {
  factory _$PromoCodeCopyWith(_PromoCode value, $Res Function(_PromoCode) _then) = __$PromoCodeCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'event_id') String eventId, String code,@JsonKey(name: 'discount_amount') double? discountAmount,@JsonKey(name: 'discount_percent') double? discountPercent,@JsonKey(name: 'max_uses') int? maxUses, int uses,@JsonKey(name: 'valid_until') DateTime? validUntil
});




}
/// @nodoc
class __$PromoCodeCopyWithImpl<$Res>
    implements _$PromoCodeCopyWith<$Res> {
  __$PromoCodeCopyWithImpl(this._self, this._then);

  final _PromoCode _self;
  final $Res Function(_PromoCode) _then;

/// Create a copy of PromoCode
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? eventId = null,Object? code = null,Object? discountAmount = freezed,Object? discountPercent = freezed,Object? maxUses = freezed,Object? uses = null,Object? validUntil = freezed,}) {
  return _then(_PromoCode(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,discountAmount: freezed == discountAmount ? _self.discountAmount : discountAmount // ignore: cast_nullable_to_non_nullable
as double?,discountPercent: freezed == discountPercent ? _self.discountPercent : discountPercent // ignore: cast_nullable_to_non_nullable
as double?,maxUses: freezed == maxUses ? _self.maxUses : maxUses // ignore: cast_nullable_to_non_nullable
as int?,uses: null == uses ? _self.uses : uses // ignore: cast_nullable_to_non_nullable
as int,validUntil: freezed == validUntil ? _self.validUntil : validUntil // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
