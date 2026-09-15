import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eventhub/core/api/supabase_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'waitlist_repository.g.dart';

class WaitlistRepository {
  final SupabaseClient _client;
  WaitlistRepository(this._client);

  Future<bool> isOnWaitlist(String eventId, String userId) async {
    final res = await _client
        .from('waitlist')
        .select('id')
        .eq('event_id', eventId)
        .eq('user_id', userId)
        .maybeSingle();
    return res != null;
  }

  Future<void> joinWaitlist(String eventId, String userId) async {
    await _client.from('waitlist').upsert({
      'event_id': eventId,
      'user_id': userId,
      'status': 'waiting',
    }, onConflict: 'event_id,user_id');
  }

  Future<void> leaveWaitlist(String eventId, String userId) async {
    await _client
        .from('waitlist')
        .delete()
        .eq('event_id', eventId)
        .eq('user_id', userId);
  }
}

@riverpod
WaitlistRepository waitlistRepository(Ref ref) {
  return WaitlistRepository(ref.watch(supabaseClientProvider));
}
