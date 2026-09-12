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
    // Supabase Auth signup
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'name': name,
        'role': role.name,
      },
    );
    
    // Fallback: If no Postgres trigger exists to create the user row, we create it here.
    // If a trigger exists, this might fail with a unique constraint violation, which we can ignore.
    if (response.user != null) {
      try {
        await _client.from('users').upsert({
          'id': response.user!.id,
          'email': email,
          'name': name,
          'role': role.name,
        });
      } catch (_) {
        // Ignore upsert error assuming trigger handled it
      }
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}

@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepository(ref.watch(supabaseClientProvider));
}
