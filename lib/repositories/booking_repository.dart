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

    final response = await _client.rpc(
      'book_ticket',
      params: {
        'p_ticket_type_id': ticketTypeId,
        'p_qty': quantity,
        'p_user_id': userId,
        'p_idem': idempotencyKey,
        if (promoCode != null && promoCode.isNotEmpty)
          'p_promo_code': promoCode,
      },
    );

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
    final response = await _client.rpc(
      'check_in',
      params: {'p_booking_id': bookingId, 'p_staff': staffId},
    );
    return response as String;
  }

  Future<Map<String, dynamic>?> validatePromoCode(
    String eventId,
    String code,
  ) async {
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

  Future<void> requestRefund(
    String bookingId,
    double amount,
    String reason,
  ) async {
    await _client.from('refunds').insert({
      'booking_id': bookingId,
      'amount': amount,
      'reason': reason,
      'status': 'pending',
    });
  }

  Future<List<Map<String, dynamic>>> getRefundRequestsForEvent(
    String eventId,
  ) async {
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
      final refund = await _client
          .from('refunds')
          .select('booking_id')
          .eq('id', refundId)
          .single();
      await _client
          .from('bookings')
          .update({'status': 'refunded'})
          .eq('id', refund['booking_id']);
    }
  }

  Future<void> transferTicket({
    required String bookingId,
    required String currentUserId,
    required String recipientEmail,
  }) async {
    final cleanEmail = recipientEmail.trim().toLowerCase();
    final recipient = await _client
        .from('users')
        .select('id, name')
        .eq('email', cleanEmail)
        .maybeSingle();

    if (recipient == null) {
      throw Exception(
        'No user found with email "$recipientEmail". Ask them to sign up first!',
      );
    }

    if (recipient['id'] == currentUserId) {
      throw Exception('You cannot transfer a ticket to yourself.');
    }

    final newQrToken = const Uuid().v4().replaceAll('-', '');

    await _client
        .from('bookings')
        .update({'user_id': recipient['id'], 'qr_token': newQrToken})
        .eq('id', bookingId)
        .eq('user_id', currentUserId);
  }

  /// Books one ticket per attendee in a group. Each gets a unique QR token.
  /// Returns the list of created booking IDs.
  Future<List<String>> bookGroupTickets({
    required String ticketTypeId,
    required String userId,
    required String eventId,
    required List<Map<String, String>> attendees,
  }) async {
    final bookingIds = <String>[];

    for (final attendee in attendees) {
      final idempotencyKey = const Uuid().v4();
      try {
        final response = await _client.rpc(
          'book_ticket',
          params: {
            'p_ticket_type_id': ticketTypeId,
            'p_qty': 1,
            'p_user_id': userId,
            'p_idem': idempotencyKey,
          },
        );

        // Annotate with attendee info on the booking metadata
        final bookingId = response?.toString() ?? idempotencyKey;
        bookingIds.add(bookingId);

        // Store attendee metadata
        try {
          await _client.from('booking_attendees').insert({
            'booking_id': bookingId,
            'attendee_name': attendee['name'] ?? '',
            'attendee_email': attendee['email'] ?? '',
          });
        } catch (_) {
          // Table may not exist yet — booking still succeeded
        }
      } catch (e) {
        // If one fails, cancel already-created ones (best effort)
        for (final id in bookingIds) {
          try {
            await _client
                .from('bookings')
                .update({'status': 'cancelled'})
                .eq('id', id);
          } catch (_) {}
        }
        rethrow;
      }
    }

    return bookingIds;
  }
}

@riverpod
BookingRepository bookingRepository(Ref ref) {
  return BookingRepository(ref.watch(supabaseClientProvider));
}
