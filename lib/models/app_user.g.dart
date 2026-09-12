// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppUser _$AppUserFromJson(Map<String, dynamic> json) => _AppUser(
  id: json['id'] as String,
  name: json['name'] as String?,
  email: json['email'] as String,
  phone: json['phone'] as String?,
  role:
      $enumDecodeNullable(_$UserRoleEnumMap, json['role']) ?? UserRole.attendee,
  fcmToken: json['fcm_token'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$AppUserToJson(_AppUser instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'phone': instance.phone,
  'role': _$UserRoleEnumMap[instance.role]!,
  'fcm_token': instance.fcmToken,
  'created_at': instance.createdAt?.toIso8601String(),
};

const _$UserRoleEnumMap = {
  UserRole.attendee: 'attendee',
  UserRole.organizer: 'organizer',
  UserRole.admin: 'admin',
};
