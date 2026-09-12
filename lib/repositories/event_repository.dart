import 'package:eventhub/core/api/supabase_client.dart';
import 'package:eventhub/models/event.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:eventhub/models/ticket_type.dart';

part 'event_repository.g.dart';

class EventRepository {
  final SupabaseClient _client;

  EventRepository(this._client);

  Future<List<Event>> getPublishedEvents() async {
    final response = await _client
        .from('events')
        .select()
        .eq('status', 'published')
        .order('start_at', ascending: true);
        
    return (response as List).map((e) => Event.fromJson(e)).toList();
  }

  Future<Event> getEventDetails(String id) async {
    final response = await _client
        .from('events')
        .select()
        .eq('id', id)
        .single();
        
    return Event.fromJson(response);
  }

  Future<List<Event>> getEventsByOrganizer(String organizerId) async {
    final response = await _client
        .from('events')
        .select()
        .eq('organizer_id', organizerId)
        .order('created_at', ascending: false);
        
    return (response as List).map((e) => Event.fromJson(e)).toList();
  }

  Future<Event> createEvent(Event event) async {
    final response = await _client
        .from('events')
        .insert(event.toJson()..remove('id')..remove('created_at')..remove('total_sold')..remove('gross_revenue'))
        .select()
        .single();
        
    return Event.fromJson(response);
  }

  Future<List<TicketType>> getTicketTypes(String eventId) async {
    final response = await _client
        .from('ticket_types')
        .select()
        .eq('event_id', eventId)
        .order('price', ascending: true);
        
    return (response as List).map((e) => TicketType.fromJson(e)).toList();
  }

  Future<TicketType> createTicketType(TicketType ticket) async {
    final response = await _client
        .from('ticket_types')
        .insert(ticket.toJson()..remove('id')..remove('quantity_sold'))
        .select()
        .single();
        
    return TicketType.fromJson(response);
  }
}

@riverpod
EventRepository eventRepository(Ref ref) {
  return EventRepository(ref.watch(supabaseClientProvider));
}
