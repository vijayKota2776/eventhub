// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(eventStats)
final eventStatsProvider = EventStatsFamily._();

final class EventStatsProvider
    extends
        $FunctionalProvider<
          AsyncValue<EventStats>,
          EventStats,
          FutureOr<EventStats>
        >
    with $FutureModifier<EventStats>, $FutureProvider<EventStats> {
  EventStatsProvider._({
    required EventStatsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'eventStatsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$eventStatsHash();

  @override
  String toString() {
    return r'eventStatsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<EventStats> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<EventStats> create(Ref ref) {
    final argument = this.argument as String;
    return eventStats(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is EventStatsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$eventStatsHash() => r'26b59dea2f0943996230a049ef1dc91b74cbc302';

final class EventStatsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<EventStats>, String> {
  EventStatsFamily._()
    : super(
        retry: null,
        name: r'eventStatsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  EventStatsProvider call(String eventId) =>
      EventStatsProvider._(argument: eventId, from: this);

  @override
  String toString() => r'eventStatsProvider';
}
