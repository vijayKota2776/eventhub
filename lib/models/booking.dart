import 'package:freezed_annotation/freezed_annotation.dart';

part 'booking.freezed.dart';
part 'booking.g.dart';

@freezed
abstract class Booking with _$Booking {
  const factory Booking({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'event_id') required String eventId,
    @JsonKey(name: 'ticket_type_id') required String ticketTypeId,
    required int quantity,
    @JsonKey(name: 'unit_price') required double unitPrice,
    @JsonKey(name: 'total_amount') required double totalAmount,
    required String status,
    @JsonKey(name: 'idempotency_key') required String idempotencyKey,
    @JsonKey(name: 'qr_token') String? qrToken,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _Booking;

  factory Booking.fromJson(Map<String, dynamic> json) =>
      _$BookingFromJson(json);
}
