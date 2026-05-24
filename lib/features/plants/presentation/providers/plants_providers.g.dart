// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plants_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$plantsRepositoryHash() => r'801f9b8b0100179effd42508163272755f4d881e';

/// See also [plantsRepository].
@ProviderFor(plantsRepository)
final plantsRepositoryProvider = Provider<PlantsRepository>.internal(
  plantsRepository,
  name: r'plantsRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$plantsRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PlantsRepositoryRef = ProviderRef<PlantsRepository>;
String _$plantsWithSpeciesHash() => r'e76ed9d383212fc46302cbce4e4e81498dab85ba';

/// Combines each plant with its resolved species for home-screen display.
///
/// Copied from [plantsWithSpecies].
@ProviderFor(plantsWithSpecies)
final plantsWithSpeciesProvider =
    AutoDisposeFutureProvider<List<PlantWithSpecies>>.internal(
  plantsWithSpecies,
  name: r'plantsWithSpeciesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$plantsWithSpeciesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PlantsWithSpeciesRef
    = AutoDisposeFutureProviderRef<List<PlantWithSpecies>>;
String _$plantsNotifierHash() => r'cf9f2f57884c48bf21febd43a379f8e8b05a8032';

/// See also [PlantsNotifier].
@ProviderFor(PlantsNotifier)
final plantsNotifierProvider =
    AutoDisposeAsyncNotifierProvider<PlantsNotifier, List<PlantModel>>.internal(
  PlantsNotifier.new,
  name: r'plantsNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$plantsNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PlantsNotifier = AutoDisposeAsyncNotifier<List<PlantModel>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
