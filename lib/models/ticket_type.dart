import 'package:freezed_annotation/freezed_annotation.dart';

part 'ticket_type.freezed.dart';
part 'ticket_type.g.dart';

@freezed
abstract class TicketType with _$TicketType {
  const factory TicketType({
    required String id,
    @JsonKey(name: 'event_id') required String eventId,
    required String name,
    required double price,
    @JsonKey(name: 'quantity_total') required int quantityTotal,
    @JsonKey(name: 'quantity_sold') @Default(0) int quantitySold,
    @JsonKey(name: 'sales_start') required DateTime salesStart,
    @JsonKey(name: 'sales_end') required DateTime salesEnd,
  }) = _TicketType;

  factory TicketType.fromJson(Map<String, dynamic> json) => _$TicketTypeFromJson(json);
}
