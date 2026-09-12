import 'package:eventhub/core/api/supabase_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'package:eventhub/models/booking.dart';

part 'booking_repository.g.dart';

class BookingRepository {
  final SupabaseClient _client;

  BookingRepository(this._client);

  Future<String> bookTicket({
    required String ticketTypeId,
    required int quantity,
    required String userId,
  }) async {
    // Generate an idempotency key
    final idempotencyKey = const Uuid().v4();

    final response = await _client.rpc('book_ticket', params: {
      'p_ticket_type_id': ticketTypeId,
      'p_qty': quantity,
      'p_user_id': userId,
      'p_idem': idempotencyKey,
    });

    return response as String; // Returns the booking ID
  }

  Future<List<Booking>> getMyBookings(String userId) async {
    final response = await _client
        .from('bookings')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List).map((e) => Booking.fromJson(e)).toList();
  }

  Future<String> checkInTicket(String bookingId, String staffId) async {
    final response = await _client.rpc('check_in', params: {
      'p_booking_id': bookingId,
      'p_staff': staffId,
    });
    return response as String;
  }
}

@riverpod
BookingRepository bookingRepository(Ref ref) {
  return BookingRepository(ref.watch(supabaseClientProvider));
}
