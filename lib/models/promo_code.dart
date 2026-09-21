import 'package:freezed_annotation/freezed_annotation.dart';

part 'promo_code.freezed.dart';
part 'promo_code.g.dart';

@freezed
abstract class PromoCode with _$PromoCode {
  const factory PromoCode({
    required String id,
    @JsonKey(name: 'event_id') required String eventId,
    required String code,
    @JsonKey(name: 'discount_amount') double? discountAmount,
    @JsonKey(name: 'discount_percent') double? discountPercent,
    @JsonKey(name: 'max_uses') int? maxUses,
    @Default(0) int uses,
    @JsonKey(name: 'valid_until') DateTime? validUntil,
  }) = _PromoCode;

  factory PromoCode.fromJson(Map<String, dynamic> json) =>
      _$PromoCodeFromJson(json);
}
