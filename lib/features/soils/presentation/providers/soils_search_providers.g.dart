// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'soils_search_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$filteredSortedSoilsHash() =>
    r'275170ce2734becb36d6a0def3438c54e01598af';

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
String _$soilSearchQueryHash() => r'b313ff7fc38416991734d056f57a545ef550e41b';

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
