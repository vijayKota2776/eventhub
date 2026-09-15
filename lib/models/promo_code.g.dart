// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'promo_code.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PromoCode _$PromoCodeFromJson(Map<String, dynamic> json) => _PromoCode(
  id: json['id'] as String,
  eventId: json['event_id'] as String,
  code: json['code'] as String,
  discountAmount: (json['discount_amount'] as num?)?.toDouble(),
  discountPercent: (json['discount_percent'] as num?)?.toDouble(),
  maxUses: (json['max_uses'] as num?)?.toInt(),
  uses: (json['uses'] as num?)?.toInt() ?? 0,
  validUntil: json['valid_until'] == null
      ? null
      : DateTime.parse(json['valid_until'] as String),
);

Map<String, dynamic> _$PromoCodeToJson(_PromoCode instance) =>
    <String, dynamic>{
      'id': instance.id,
      'event_id': instance.eventId,
      'code': instance.code,
      'discount_amount': instance.discountAmount,
      'discount_percent': instance.discountPercent,
      'max_uses': instance.maxUses,
      'uses': instance.uses,
      'valid_until': instance.validUntil?.toIso8601String(),
    };
