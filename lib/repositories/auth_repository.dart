import 'package:eventhub/core/api/supabase_client.dart';
import 'package:eventhub/models/app_user.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_repository.g.dart';

class AuthRepository {
  final SupabaseClient _client;

  AuthRepository(this._client);

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  User? get currentUser => _client.auth.currentUser;

  Future<AppUser?> getAppUser(String userId) async {
    try {
      final response = await _client
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();
      if (response == null) return null;
      return AppUser.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required UserRole role,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'name': name, 'role': role.name},
    );

    if (response.user != null) {
      try {
        await _client.from('users').upsert({
          'id': response.user!.id,
          'email': email,
          'name': name,
          'role': role.name,
        });
      } catch (_) {}
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<List<AppUser>> getAllUsers() async {
    final response = await _client
        .from('users')
        .select()
        .order('created_at', ascending: false);
    return (response as List).map((u) => AppUser.fromJson(u)).toList();
  }

  Future<void> updateUserRole(String userId, UserRole newRole) async {
    await _client.from('users').update({'role': newRole.name}).eq('id', userId);
  }
}

@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepository(ref.watch(supabaseClientProvider));
}
