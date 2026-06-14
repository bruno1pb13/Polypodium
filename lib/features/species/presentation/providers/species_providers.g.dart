// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'species_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$speciesRepositoryHash() => r'60c995257591df82175f8a29f0a08cbceedbea0c';

/// See also [speciesRepository].
@ProviderFor(speciesRepository)
final speciesRepositoryProvider = Provider<SpeciesRepository>.internal(
  speciesRepository,
  name: r'speciesRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$speciesRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SpeciesRepositoryRef = ProviderRef<SpeciesRepository>;
String _$speciesNotifierHash() => r'9c16f8c6f4f92d14dda500f1e63be388814c98c5';

/// See also [SpeciesNotifier].
@ProviderFor(SpeciesNotifier)
final speciesNotifierProvider = AutoDisposeStreamNotifierProvider<
    SpeciesNotifier, List<SpeciesModel>>.internal(
  SpeciesNotifier.new,
  name: r'speciesNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$speciesNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SpeciesNotifier = AutoDisposeStreamNotifier<List<SpeciesModel>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
