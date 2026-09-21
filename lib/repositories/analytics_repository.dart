import 'package:eventhub/core/api/supabase_client.dart';
import 'package:eventhub/models/event_stats.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'analytics_repository.g.dart';

class AnalyticsRepository {
  final SupabaseClient _client;

  AnalyticsRepository(this._client);

  Future<EventStats> getEventStats(String eventId) async {
    final response = await _client
        .from('v_event_stats')
        .select()
        .eq('id', eventId)
        .maybeSingle();

    if (response == null) {
      // If the view returns null (e.g., no bookings yet), return a default stats object
      return EventStats(
        id: eventId,
        title: 'Event',
        ticketsSold: 0,
        revenue: 0,
        attended: 0,
        attendanceRate: 0,
      );
    }

    return EventStats.fromJson(response);
  }

  Future<Map<String, dynamic>> getPlatformStats() async {
    try {
      final usersRes = await _client.from('users').select('id, role');
      final eventsRes = await _client
          .from('events')
          .select('id, status, gross_revenue, total_sold');
      final bookingsRes = await _client
          .from('bookings')
          .select('id, total_amount, status, created_at');

      final usersList = (usersRes as List);
      final eventsList = (eventsRes as List);
      final bookingsList = (bookingsRes as List);

      final totalUsers = usersList.length;
      final totalAttendees = usersList
          .where((u) => u['role'] == 'attendee')
          .length;
      final totalOrganizers = usersList
          .where((u) => u['role'] == 'organizer')
          .length;

      final totalEvents = eventsList.length;
      final publishedEvents = eventsList
          .where((e) => e['status'] == 'published')
          .length;
      final pendingEvents = eventsList
          .where((e) => e['status'] != 'published')
          .length;

      final totalBookings = bookingsList.length;
      double totalRevenue = 0;
      for (final b in bookingsList) {
        if (b['status'] == 'confirmed' || b['status'] == 'completed') {
          totalRevenue += (b['total_amount'] as num?)?.toDouble() ?? 0;
        }
      }

      return {
        'totalUsers': totalUsers,
        'totalAttendees': totalAttendees,
        'totalOrganizers': totalOrganizers,
        'totalEvents': totalEvents,
        'publishedEvents': publishedEvents,
        'pendingEvents': pendingEvents,
        'totalBookings': totalBookings,
        'totalRevenue': totalRevenue,
      };
    } catch (e) {
      return {
        'totalUsers': 0,
        'totalAttendees': 0,
        'totalOrganizers': 0,
        'totalEvents': 0,
        'publishedEvents': 0,
        'pendingEvents': 0,
        'totalBookings': 0,
        'totalRevenue': 0.0,
      };
    }
  }
}

@riverpod
AnalyticsRepository analyticsRepository(Ref ref) {
  return AnalyticsRepository(ref.watch(supabaseClientProvider));
}
