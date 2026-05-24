// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'locations_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$locationsRepositoryHash() =>
    r'924db1a150a1e4ee682036ae538940b67a20c9ea';

/// See also [locationsRepository].
@ProviderFor(locationsRepository)
final locationsRepositoryProvider = Provider<LocationsRepository>.internal(
  locationsRepository,
  name: r'locationsRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$locationsRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LocationsRepositoryRef = ProviderRef<LocationsRepository>;
String _$locationsNotifierHash() => r'e4c8e3fc78823f533fcb386de98ba8b3fddd3e76';

/// See also [LocationsNotifier].
@ProviderFor(LocationsNotifier)
final locationsNotifierProvider = AutoDisposeAsyncNotifierProvider<
    LocationsNotifier, List<LocationModel>>.internal(
  LocationsNotifier.new,
  name: r'locationsNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$locationsNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$LocationsNotifier = AutoDisposeAsyncNotifier<List<LocationModel>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
