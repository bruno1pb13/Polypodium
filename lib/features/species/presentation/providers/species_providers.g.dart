// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'species_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$speciesRepositoryHash() => r'a804d1475e9b985f4c7dabd618463fd0aed74e28';

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
String _$speciesNotifierHash() => r'cb3230eb3f7f554cb079a7538f9a4628d9c8abc5';

/// See also [SpeciesNotifier].
@ProviderFor(SpeciesNotifier)
final speciesNotifierProvider = AutoDisposeAsyncNotifierProvider<
    SpeciesNotifier, List<SpeciesModel>>.internal(
  SpeciesNotifier.new,
  name: r'speciesNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$speciesNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SpeciesNotifier = AutoDisposeAsyncNotifier<List<SpeciesModel>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
