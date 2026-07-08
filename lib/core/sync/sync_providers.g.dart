// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(syncService)
final syncServiceProvider = SyncServiceProvider._();

final class SyncServiceProvider
    extends $FunctionalProvider<SyncService, SyncService, SyncService>
    with $Provider<SyncService> {
  SyncServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'syncServiceProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$syncServiceHash();

  @$internal
  @override
  $ProviderElement<SyncService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SyncService create(Ref ref) {
    return syncService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SyncService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SyncService>(value),
    );
  }
}

String _$syncServiceHash() => r'791c01c68a6b89a1c88dfd019d65010eab2abceb';

@ProviderFor(pendingSyncCount)
final pendingSyncCountProvider = PendingSyncCountProvider._();

final class PendingSyncCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  PendingSyncCountProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'pendingSyncCountProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$pendingSyncCountHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return pendingSyncCount(ref);
  }
}

String _$pendingSyncCountHash() => r'b6144ec8c6bb629afb7be76d1a8d9b34b0855313';

@ProviderFor(SyncNotifier)
final syncNotifierProvider = SyncNotifierProvider._();

final class SyncNotifierProvider
    extends $NotifierProvider<SyncNotifier, AsyncValue<SyncResult?>> {
  SyncNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'syncNotifierProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$syncNotifierHash();

  @$internal
  @override
  SyncNotifier create() => SyncNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<SyncResult?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<SyncResult?>>(value),
    );
  }
}

String _$syncNotifierHash() => r'6c65e0188b48666f6efa80f049834ee70d11eaf3';

abstract class _$SyncNotifier extends $Notifier<AsyncValue<SyncResult?>> {
  AsyncValue<SyncResult?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<SyncResult?>, AsyncValue<SyncResult?>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<SyncResult?>, AsyncValue<SyncResult?>>,
        AsyncValue<SyncResult?>,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}
