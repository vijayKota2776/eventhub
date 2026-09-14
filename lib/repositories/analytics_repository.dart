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
}

@riverpod
AnalyticsRepository analyticsRepository(Ref ref) {
  return AnalyticsRepository(ref.watch(supabaseClientProvider));
}
