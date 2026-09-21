import 'package:eventhub/models/app_user.dart';
import 'package:eventhub/repositories/auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_provider.g.dart';

@Riverpod(keepAlive: true)
class AuthController extends _$AuthController {
  @override
  FutureOr<AppUser?> build() async {
    final authRepo = ref.watch(authRepositoryProvider);
    final user = authRepo.currentUser;
    if (user == null) return null;

    final appUser = await authRepo.getAppUser(user.id);
    return appUser ??
        AppUser(
          id: user.id,
          email: user.email ?? '',
          name: user.userMetadata?['name'] ?? 'User',
          role: user.userMetadata?['role'] == 'organizer'
              ? UserRole.organizer
              : user.userMetadata?['role'] == 'admin'
              ? UserRole.admin
              : UserRole.attendee,
        );
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await ref
          .read(authRepositoryProvider)
          .signIn(email: email, password: password);
      ref.invalidateSelf();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> signUp(
    String email,
    String password,
    String name,
    UserRole role,
  ) async {
    state = const AsyncValue.loading();
    try {
      await ref
          .read(authRepositoryProvider)
          .signUp(email: email, password: password, name: name, role: role);
      ref.invalidateSelf();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    ref.invalidateSelf();
  }
}
