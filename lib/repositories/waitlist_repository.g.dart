// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'waitlist_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(waitlistRepository)
final waitlistRepositoryProvider = WaitlistRepositoryProvider._();

final class WaitlistRepositoryProvider
    extends
        $FunctionalProvider<
          WaitlistRepository,
          WaitlistRepository,
          WaitlistRepository
        >
    with $Provider<WaitlistRepository> {
  WaitlistRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'waitlistRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$waitlistRepositoryHash();

  @$internal
  @override
  $ProviderElement<WaitlistRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WaitlistRepository create(Ref ref) {
    return waitlistRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WaitlistRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WaitlistRepository>(value),
    );
  }
}

String _$waitlistRepositoryHash() =>
    r'eec2f69a064e24fe183ba650d5fa19095fec1df5';
