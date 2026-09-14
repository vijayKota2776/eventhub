import 'package:eventhub/models/event_stats.dart';
import 'package:eventhub/repositories/analytics_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'analytics_provider.g.dart';

@riverpod
Future<EventStats> eventStats(Ref ref, String eventId) {
  return ref.watch(analyticsRepositoryProvider).getEventStats(eventId);
}
