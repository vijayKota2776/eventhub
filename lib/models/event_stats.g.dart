// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EventStats _$EventStatsFromJson(Map<String, dynamic> json) => _EventStats(
  id: json['id'] as String,
  title: json['title'] as String,
  ticketsSold: (json['tickets_sold'] as num?)?.toInt() ?? 0,
  revenue: json['revenue'] as num? ?? 0,
  attended: (json['attended'] as num?)?.toInt() ?? 0,
  attendanceRate: json['attendance_rate'] as num? ?? 0,
);

Map<String, dynamic> _$EventStatsToJson(_EventStats instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'tickets_sold': instance.ticketsSold,
      'revenue': instance.revenue,
      'attended': instance.attended,
      'attendance_rate': instance.attendanceRate,
    };
