// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Booking _$BookingFromJson(Map<String, dynamic> json) => _Booking(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  eventId: json['event_id'] as String,
  ticketTypeId: json['ticket_type_id'] as String,
  quantity: (json['quantity'] as num).toInt(),
  unitPrice: (json['unit_price'] as num).toDouble(),
  totalAmount: (json['total_amount'] as num).toDouble(),
  status: json['status'] as String,
  idempotencyKey: json['idempotency_key'] as String,
  qrToken: json['qr_token'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$BookingToJson(_Booking instance) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'event_id': instance.eventId,
  'ticket_type_id': instance.ticketTypeId,
  'quantity': instance.quantity,
  'unit_price': instance.unitPrice,
  'total_amount': instance.totalAmount,
  'status': instance.status,
  'idempotency_key': instance.idempotencyKey,
  'qr_token': instance.qrToken,
  'created_at': instance.createdAt?.toIso8601String(),
};
