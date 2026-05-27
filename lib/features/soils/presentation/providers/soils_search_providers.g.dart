// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'soils_search_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$filteredSortedSoilsHash() =>
    r'db55dc539caeb5294e79b8ad193d04d2eae83d65';

/// See also [filteredSortedSoils].
@ProviderFor(filteredSortedSoils)
final filteredSortedSoilsProvider =
    AutoDisposeFutureProvider<List<SoilModel>>.internal(
  filteredSortedSoils,
  name: r'filteredSortedSoilsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$filteredSortedSoilsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FilteredSortedSoilsRef = AutoDisposeFutureProviderRef<List<SoilModel>>;
String _$soilSearchQueryHash() => r'133aa3046b45f7b0b3543600ef989213bb3a926b';

/// See also [SoilSearchQuery].
@ProviderFor(SoilSearchQuery)
final soilSearchQueryProvider =
    AutoDisposeNotifierProvider<SoilSearchQuery, String>.internal(
  SoilSearchQuery.new,
  name: r'soilSearchQueryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$soilSearchQueryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SoilSearchQuery = AutoDisposeNotifier<String>;
String _$soilSortOptionNotifierHash() =>
    r'7bba56a23141084cc9d214c94320e896264788da';

/// See also [SoilSortOptionNotifier].
@ProviderFor(SoilSortOptionNotifier)
final soilSortOptionNotifierProvider = AutoDisposeNotifierProvider<
    SoilSortOptionNotifier, SoilSortOption>.internal(
  SoilSortOptionNotifier.new,
  name: r'soilSortOptionNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$soilSortOptionNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SoilSortOptionNotifier = AutoDisposeNotifier<SoilSortOption>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
