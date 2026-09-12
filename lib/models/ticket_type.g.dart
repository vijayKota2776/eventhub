// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ticket_type.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TicketType _$TicketTypeFromJson(Map<String, dynamic> json) => _TicketType(
  id: json['id'] as String,
  eventId: json['event_id'] as String,
  name: json['name'] as String,
  price: (json['price'] as num).toDouble(),
  quantityTotal: (json['quantity_total'] as num).toInt(),
  quantitySold: (json['quantity_sold'] as num?)?.toInt() ?? 0,
  salesStart: DateTime.parse(json['sales_start'] as String),
  salesEnd: DateTime.parse(json['sales_end'] as String),
);

Map<String, dynamic> _$TicketTypeToJson(_TicketType instance) =>
    <String, dynamic>{
      'id': instance.id,
      'event_id': instance.eventId,
      'name': instance.name,
      'price': instance.price,
      'quantity_total': instance.quantityTotal,
      'quantity_sold': instance.quantitySold,
      'sales_start': instance.salesStart.toIso8601String(),
      'sales_end': instance.salesEnd.toIso8601String(),
    };
