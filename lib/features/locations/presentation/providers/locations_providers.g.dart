// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'locations_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(locationsRepository)
final locationsRepositoryProvider = LocationsRepositoryProvider._();

final class LocationsRepositoryProvider extends $FunctionalProvider<
    LocationsRepository,
    LocationsRepository,
    LocationsRepository> with $Provider<LocationsRepository> {
  LocationsRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'locationsRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$locationsRepositoryHash();

  @$internal
  @override
  $ProviderElement<LocationsRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LocationsRepository create(Ref ref) {
    return locationsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocationsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocationsRepository>(value),
    );
  }
}

String _$locationsRepositoryHash() =>
    r'924db1a150a1e4ee682036ae538940b67a20c9ea';

@ProviderFor(LocationsNotifier)
final locationsNotifierProvider = LocationsNotifierProvider._();

final class LocationsNotifierProvider
    extends $StreamNotifierProvider<LocationsNotifier, List<LocationModel>> {
  LocationsNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'locationsNotifierProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$locationsNotifierHash();

  @$internal
  @override
  LocationsNotifier create() => LocationsNotifier();
}

String _$locationsNotifierHash() => r'dc348c8912330f056b30ebfab0f1a5f9e3cc626c';

abstract class _$LocationsNotifier
    extends $StreamNotifier<List<LocationModel>> {
  Stream<List<LocationModel>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<LocationModel>>, List<LocationModel>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<LocationModel>>, List<LocationModel>>,
        AsyncValue<List<LocationModel>>,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}
