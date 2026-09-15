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
    String? promoCode,
  }) async {
    // Generate an idempotency key
    final idempotencyKey = const Uuid().v4();

    final response = await _client.rpc('book_ticket', params: {
      'p_ticket_type_id': ticketTypeId,
      'p_qty': quantity,
      'p_user_id': userId,
      'p_idem': idempotencyKey,
      if (promoCode != null && promoCode.isNotEmpty) 'p_promo_code': promoCode,
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

  Future<Map<String, dynamic>?> validatePromoCode(String eventId, String code) async {
    final response = await _client
        .from('promo_codes')
        .select()
        .eq('event_id', eventId)
        .eq('code', code)
        .maybeSingle();

    if (response == null) return null;

    // Check expiration and usage
    if (response['valid_until'] != null) {
      if (DateTime.parse(response['valid_until']).isBefore(DateTime.now())) {
        return null; // Expired
      }
    }
    if (response['max_uses'] != null) {
      if (response['uses'] >= response['max_uses']) {
        return null; // Exhausted
      }
    }

    return response;
  }
  Future<void> requestRefund(String bookingId, double amount, String reason) async {
    await _client.from('refunds').insert({
      'booking_id': bookingId,
      'amount': amount,
      'reason': reason,
      'status': 'pending',
    });
  }

  Future<List<Map<String, dynamic>>> getRefundRequestsForEvent(String eventId) async {
    final response = await _client
        .from('refunds')
        .select('*, bookings!inner(event_id)')
        .eq('bookings.event_id', eventId)
        .order('created_at', ascending: false);
    return (response as List).cast<Map<String, dynamic>>();
  }

  Future<void> updateRefundStatus(String refundId, String status) async {
    await _client.from('refunds').update({'status': status}).eq('id', refundId);
    if (status == 'approved') {
      // Update booking status to refunded
      final refund = await _client.from('refunds').select('booking_id').eq('id', refundId).single();
      await _client.from('bookings').update({'status': 'refunded'}).eq('id', refund['booking_id']);
    }
  }
}

@riverpod
BookingRepository bookingRepository(Ref ref) {
  return BookingRepository(ref.watch(supabaseClientProvider));
}
