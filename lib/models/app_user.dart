import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_user.freezed.dart';
part 'app_user.g.dart';

enum UserRole { attendee, organizer, admin }

@freezed
sealed class AppUser with _$AppUser {
  const factory AppUser({
    required String id,
    String? name,
    required String email,
    String? phone,
    @Default(UserRole.attendee) UserRole role,
    @JsonKey(name: 'fcm_token') String? fcmToken,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _AppUser;

  factory AppUser.fromJson(Map<String, dynamic> json) =>
      _$AppUserFromJson(json);
}
