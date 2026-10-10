// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plant_search_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PlantSearchQuery)
final plantSearchQueryProvider = PlantSearchQueryProvider._();

final class PlantSearchQueryProvider
    extends $NotifierProvider<PlantSearchQuery, String> {
  PlantSearchQueryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'plantSearchQueryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$plantSearchQueryHash();

  @$internal
  @override
  PlantSearchQuery create() => PlantSearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$plantSearchQueryHash() => r'253e815c1b32167df85402581e64df3f8ff2bc5e';

abstract class _$PlantSearchQuery extends $Notifier<String> {
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

@ProviderFor(PlantSortOptionNotifier)
final plantSortOptionNotifierProvider = PlantSortOptionNotifierProvider._();

final class PlantSortOptionNotifierProvider
    extends $NotifierProvider<PlantSortOptionNotifier, PlantSortOption> {
  PlantSortOptionNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'plantSortOptionNotifierProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$plantSortOptionNotifierHash();

  @$internal
  @override
  PlantSortOptionNotifier create() => PlantSortOptionNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlantSortOption value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlantSortOption>(value),
    );
  }
}

String _$plantSortOptionNotifierHash() =>
    r'7061a02f0c90a141c16ff2193720224ea851487f';

abstract class _$PlantSortOptionNotifier extends $Notifier<PlantSortOption> {
  PlantSortOption build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<PlantSortOption, PlantSortOption>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<PlantSortOption, PlantSortOption>,
        PlantSortOption,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}

/// Whether the Home list also shows plants that are no longer active (dead,
/// donated or archived). Off by default.

@ProviderFor(PlantShowArchivedNotifier)
final plantShowArchivedNotifierProvider = PlantShowArchivedNotifierProvider._();

/// Whether the Home list also shows plants that are no longer active (dead,
/// donated or archived). Off by default.
final class PlantShowArchivedNotifierProvider
    extends $NotifierProvider<PlantShowArchivedNotifier, bool> {
  /// Whether the Home list also shows plants that are no longer active (dead,
  /// donated or archived). Off by default.
  PlantShowArchivedNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'plantShowArchivedNotifierProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$plantShowArchivedNotifierHash();

  @$internal
  @override
  PlantShowArchivedNotifier create() => PlantShowArchivedNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$plantShowArchivedNotifierHash() =>
    r'c4e30dc3d4f1bccf52c7462cbff17a4bdd0c2551';

/// Whether the Home list also shows plants that are no longer active (dead,
/// donated or archived). Off by default.

abstract class _$PlantShowArchivedNotifier extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<bool, bool>, bool, Object?, Object?>;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(filteredSortedPlants)
final filteredSortedPlantsProvider = FilteredSortedPlantsProvider._();

final class FilteredSortedPlantsProvider extends $FunctionalProvider<
        AsyncValue<List<PlantWithSpecies>>,
        List<PlantWithSpecies>,
        FutureOr<List<PlantWithSpecies>>>
    with
        $FutureModifier<List<PlantWithSpecies>>,
        $FutureProvider<List<PlantWithSpecies>> {
  FilteredSortedPlantsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'filteredSortedPlantsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$filteredSortedPlantsHash();

  @$internal
  @override
  $FutureProviderElement<List<PlantWithSpecies>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<PlantWithSpecies>> create(Ref ref) {
    return filteredSortedPlants(ref);
  }
}

String _$filteredSortedPlantsHash() =>
    r'00ac04cadf4e4b63858b2f9c949f1d6b365a1322';
