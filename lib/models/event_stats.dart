import 'package:freezed_annotation/freezed_annotation.dart';

part 'event_stats.freezed.dart';
part 'event_stats.g.dart';

@freezed
abstract class EventStats with _$EventStats {
  const factory EventStats({
    required String id,
    required String title,
    @JsonKey(name: 'tickets_sold') @Default(0) int ticketsSold,
    @Default(0) num revenue,
    @Default(0) int attended,
    @JsonKey(name: 'attendance_rate') @Default(0) num attendanceRate,
  }) = _EventStats;

  factory EventStats.fromJson(Map<String, dynamic> json) =>
      _$EventStatsFromJson(json);
}
