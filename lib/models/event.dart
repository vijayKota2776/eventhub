import 'package:freezed_annotation/freezed_annotation.dart';

part 'event.freezed.dart';
part 'event.g.dart';

@freezed
abstract class Event with _$Event {
  const factory Event({
    required String id,
    @JsonKey(name: 'organizer_id') required String organizerId,
    required String title,
    String? description,
    required String venue,
    required String city,
    @JsonKey(name: 'start_at') required DateTime startAt,
    @JsonKey(name: 'end_at') required DateTime endAt,
    @JsonKey(name: 'banner_url') String? bannerUrl,
    required String category,
    @Default('draft') String status,
    @JsonKey(name: 'total_sold') @Default(0) int totalSold,
    @JsonKey(name: 'gross_revenue') @Default(0) num grossRevenue,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _Event;

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);
}
