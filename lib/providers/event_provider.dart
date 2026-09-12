import 'package:eventhub/models/event.dart';
import 'package:eventhub/repositories/event_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'event_provider.g.dart';

@riverpod
Future<List<Event>> publishedEvents(Ref ref) {
  return ref.watch(eventRepositoryProvider).getPublishedEvents();
}

@riverpod
Future<Event> eventDetails(Ref ref, String eventId) {
  return ref.watch(eventRepositoryProvider).getEventDetails(eventId);
}
