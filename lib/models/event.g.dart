// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Event _$EventFromJson(Map<String, dynamic> json) => _Event(
  id: json['id'] as String,
  organizerId: json['organizer_id'] as String,
  title: json['title'] as String,
  description: json['description'] as String?,
  venue: json['venue'] as String,
  city: json['city'] as String,
  startAt: DateTime.parse(json['start_at'] as String),
  endAt: DateTime.parse(json['end_at'] as String),
  bannerUrl: json['banner_url'] as String?,
  category: json['category'] as String,
  status: json['status'] as String? ?? 'draft',
  totalSold: (json['total_sold'] as num?)?.toInt() ?? 0,
  grossRevenue: json['gross_revenue'] as num? ?? 0,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$EventToJson(_Event instance) => <String, dynamic>{
  'id': instance.id,
  'organizer_id': instance.organizerId,
  'title': instance.title,
  'description': instance.description,
  'venue': instance.venue,
  'city': instance.city,
  'start_at': instance.startAt.toIso8601String(),
  'end_at': instance.endAt.toIso8601String(),
  'banner_url': instance.bannerUrl,
  'category': instance.category,
  'status': instance.status,
  'total_sold': instance.totalSold,
  'gross_revenue': instance.grossRevenue,
  'created_at': instance.createdAt?.toIso8601String(),
};
