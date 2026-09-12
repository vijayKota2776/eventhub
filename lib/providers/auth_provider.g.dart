// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AuthController)
final authControllerProvider = AuthControllerProvider._();

final class AuthControllerProvider
    extends $AsyncNotifierProvider<AuthController, AppUser?> {
  AuthControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authControllerHash();

  @$internal
  @override
  AuthController create() => AuthController();
}

String _$authControllerHash() => r'229c569ec23ae9befdf955ab8a53f070c39f35f1';

abstract class _$AuthController extends $AsyncNotifier<AppUser?> {
  FutureOr<AppUser?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<AppUser?>, AppUser?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AppUser?>, AppUser?>,
              AsyncValue<AppUser?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
