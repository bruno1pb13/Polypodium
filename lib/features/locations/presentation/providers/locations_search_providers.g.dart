// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'locations_search_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$filteredSortedLocationsHash() =>
    r'936fa77daab0b25ed861c2fa2e527c7e53e90374';

/// See also [filteredSortedLocations].
@ProviderFor(filteredSortedLocations)
final filteredSortedLocationsProvider =
    AutoDisposeFutureProvider<List<LocationModel>>.internal(
  filteredSortedLocations,
  name: r'filteredSortedLocationsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$filteredSortedLocationsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FilteredSortedLocationsRef
    = AutoDisposeFutureProviderRef<List<LocationModel>>;
String _$locationSearchQueryHash() =>
    r'd458810aaf3f7fc98d34f1e47837b12105c48137';

/// See also [LocationSearchQuery].
@ProviderFor(LocationSearchQuery)
final locationSearchQueryProvider =
    AutoDisposeNotifierProvider<LocationSearchQuery, String>.internal(
  LocationSearchQuery.new,
  name: r'locationSearchQueryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$locationSearchQueryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$LocationSearchQuery = AutoDisposeNotifier<String>;
String _$locationSortOptionNotifierHash() =>
    r'c9f24d02106a2183e75b82ecc7f725899899ae59';

/// See also [LocationSortOptionNotifier].
@ProviderFor(LocationSortOptionNotifier)
final locationSortOptionNotifierProvider = AutoDisposeNotifierProvider<
    LocationSortOptionNotifier, LocationSortOption>.internal(
  LocationSortOptionNotifier.new,
  name: r'locationSortOptionNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$locationSortOptionNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$LocationSortOptionNotifier = AutoDisposeNotifier<LocationSortOption>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
