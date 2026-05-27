// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'species_search_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$filteredSortedSpeciesHash() =>
    r'c7a790716bbb3615b59e7eb59f7c74c3dab5cff3';

/// See also [filteredSortedSpecies].
@ProviderFor(filteredSortedSpecies)
final filteredSortedSpeciesProvider =
    AutoDisposeFutureProvider<List<SpeciesModel>>.internal(
  filteredSortedSpecies,
  name: r'filteredSortedSpeciesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$filteredSortedSpeciesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FilteredSortedSpeciesRef
    = AutoDisposeFutureProviderRef<List<SpeciesModel>>;
String _$speciesSearchQueryHash() =>
    r'9e73842d1c51d494ffe3b23a8b05b1d6c3d73373';

/// See also [SpeciesSearchQuery].
@ProviderFor(SpeciesSearchQuery)
final speciesSearchQueryProvider =
    AutoDisposeNotifierProvider<SpeciesSearchQuery, String>.internal(
  SpeciesSearchQuery.new,
  name: r'speciesSearchQueryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$speciesSearchQueryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SpeciesSearchQuery = AutoDisposeNotifier<String>;
String _$speciesSortOptionNotifierHash() =>
    r'f5b9fccf188eb671dee2985db33c3a64991cc8c7';

/// See also [SpeciesSortOptionNotifier].
@ProviderFor(SpeciesSortOptionNotifier)
final speciesSortOptionNotifierProvider = AutoDisposeNotifierProvider<
    SpeciesSortOptionNotifier, SpeciesSortOption>.internal(
  SpeciesSortOptionNotifier.new,
  name: r'speciesSortOptionNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$speciesSortOptionNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SpeciesSortOptionNotifier = AutoDisposeNotifier<SpeciesSortOption>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
