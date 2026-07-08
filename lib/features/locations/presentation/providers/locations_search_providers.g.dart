// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'locations_search_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LocationSearchQuery)
final locationSearchQueryProvider = LocationSearchQueryProvider._();

final class LocationSearchQueryProvider
    extends $NotifierProvider<LocationSearchQuery, String> {
  LocationSearchQueryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'locationSearchQueryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$locationSearchQueryHash();

  @$internal
  @override
  LocationSearchQuery create() => LocationSearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$locationSearchQueryHash() =>
    r'd458810aaf3f7fc98d34f1e47837b12105c48137';

abstract class _$LocationSearchQuery extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<String, String>, String, Object?, Object?>;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(LocationSortOptionNotifier)
final locationSortOptionNotifierProvider =
    LocationSortOptionNotifierProvider._();

final class LocationSortOptionNotifierProvider
    extends $NotifierProvider<LocationSortOptionNotifier, LocationSortOption> {
  LocationSortOptionNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'locationSortOptionNotifierProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$locationSortOptionNotifierHash();

  @$internal
  @override
  LocationSortOptionNotifier create() => LocationSortOptionNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocationSortOption value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocationSortOption>(value),
    );
  }
}

String _$locationSortOptionNotifierHash() =>
    r'c9f24d02106a2183e75b82ecc7f725899899ae59';

abstract class _$LocationSortOptionNotifier
    extends $Notifier<LocationSortOption> {
  LocationSortOption build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<LocationSortOption, LocationSortOption>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<LocationSortOption, LocationSortOption>,
        LocationSortOption,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(filteredSortedLocations)
final filteredSortedLocationsProvider = FilteredSortedLocationsProvider._();

final class FilteredSortedLocationsProvider extends $FunctionalProvider<
        AsyncValue<List<LocationModel>>,
        List<LocationModel>,
        FutureOr<List<LocationModel>>>
    with
        $FutureModifier<List<LocationModel>>,
        $FutureProvider<List<LocationModel>> {
  FilteredSortedLocationsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'filteredSortedLocationsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$filteredSortedLocationsHash();

  @$internal
  @override
  $FutureProviderElement<List<LocationModel>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<LocationModel>> create(Ref ref) {
    return filteredSortedLocations(ref);
  }
}

String _$filteredSortedLocationsHash() =>
    r'604ee9d2e47b4717380bd2b56e0458ce8a05aa57';
