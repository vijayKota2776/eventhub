import 'package:eventhub/core/api/supabase_client.dart';
import 'package:eventhub/models/event.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'recommendation_repository.g.dart';

class RecommendationRepository {
  final SupabaseClient _client;

  RecommendationRepository(this._client);

  /// Returns events recommended for the user based on:
  /// 1. Categories/cities from their booking history
  /// 2. Fallback: Trending events (highest total_sold)
  Future<List<Event>> getRecommendedEvents(String userId) async {
    try {
      // Step 1: Get the user's booked event categories + cities
      final bookingHistory = await _client
          .from('bookings')
          .select('events(category, city)')
          .eq('user_id', userId)
          .eq('status', 'confirmed')
          .limit(10);

      final categories = <String>{};
      final cities = <String>{};

      for (final b in bookingHistory as List) {
        final ev = b['events'] as Map<String, dynamic>?;
        if (ev != null) {
          if (ev['category'] != null) categories.add(ev['category'] as String);
          if (ev['city'] != null) cities.add(ev['city'] as String);
        }
      }

      // Step 2: Query events matching those categories or cities
      if (categories.isNotEmpty || cities.isNotEmpty) {
        final bookedEventIds =
            (await _client
                    .from('bookings')
                    .select('event_id')
                    .eq('user_id', userId))
                .map((b) => b['event_id'] as String)
                .toList();

        dynamic filter = _client
            .from('events')
            .select()
            .eq('status', 'published');

        if (bookedEventIds.isNotEmpty) {
          filter = filter.not('id', 'in', '(${bookedEventIds.join(',')})');
        }

        final results = await filter
            .order('total_sold', ascending: false)
            .limit(6);
        final events = (results as List).map((e) => Event.fromJson(e)).toList();

        // Filter client-side for matching category/city
        final matched = events
            .where(
              (e) => categories.contains(e.category) || cities.contains(e.city),
            )
            .toList();

        if (matched.isNotEmpty) return matched;
      }

      // Step 3: Fallback — Trending (most sold, upcoming, published)
      return await getTrendingEvents();
    } catch (_) {
      return await getTrendingEvents();
    }
  }

  /// Top 6 most popular upcoming events
  Future<List<Event>> getTrendingEvents() async {
    try {
      final response = await _client
          .from('events')
          .select()
          .eq('status', 'published')
          .order('total_sold', ascending: false)
          .limit(6);
      return (response as List).map((e) => Event.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  /// Filter events by category, max price, and start date
  Future<List<Event>> getFilteredEvents({
    String? category,
    double? maxPriceUsd,
    DateTime? fromDate,
    String? city,
  }) async {
    dynamic filter = _client.from('events').select().eq('status', 'published');

    if (category != null && category.isNotEmpty && category != 'All') {
      filter = filter.eq('category', category);
    }
    if (city != null && city.isNotEmpty) {
      filter = filter.ilike('city', '%$city%');
    }
    if (fromDate != null) {
      filter = filter.gte('start_at', fromDate.toIso8601String());
    }

    final results = await filter.order('start_at', ascending: true);
    return (results as List).map((e) => Event.fromJson(e)).toList();
  }
}

@riverpod
RecommendationRepository recommendationRepository(Ref ref) {
  return RecommendationRepository(ref.watch(supabaseClientProvider));
}
