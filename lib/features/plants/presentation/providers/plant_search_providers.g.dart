// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plant_search_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$filteredSortedPlantsHash() =>
    r'89818c353fac8c377ba1ab8664859cd94c1f5202';

/// See also [filteredSortedPlants].
@ProviderFor(filteredSortedPlants)
final filteredSortedPlantsProvider =
    AutoDisposeFutureProvider<List<PlantWithSpecies>>.internal(
  filteredSortedPlants,
  name: r'filteredSortedPlantsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$filteredSortedPlantsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FilteredSortedPlantsRef
    = AutoDisposeFutureProviderRef<List<PlantWithSpecies>>;
String _$plantSearchQueryHash() => r'938e2573bdf25bdbb0b6273d1b020b90c3234324';

/// See also [PlantSearchQuery].
@ProviderFor(PlantSearchQuery)
final plantSearchQueryProvider =
    AutoDisposeNotifierProvider<PlantSearchQuery, String>.internal(
  PlantSearchQuery.new,
  name: r'plantSearchQueryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$plantSearchQueryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PlantSearchQuery = AutoDisposeNotifier<String>;
String _$plantSortOptionNotifierHash() =>
    r'7061a02f0c90a141c16ff2193720224ea851487f';

/// See also [PlantSortOptionNotifier].
@ProviderFor(PlantSortOptionNotifier)
final plantSortOptionNotifierProvider = AutoDisposeNotifierProvider<
    PlantSortOptionNotifier, PlantSortOption>.internal(
  PlantSortOptionNotifier.new,
  name: r'plantSortOptionNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$plantSortOptionNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PlantSortOptionNotifier = AutoDisposeNotifier<PlantSortOption>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
