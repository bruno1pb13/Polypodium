// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'soils_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$soilsRepositoryHash() => r'adc2e770e2f6480e6a42f0b0acc7866f11675b53';

/// See also [soilsRepository].
@ProviderFor(soilsRepository)
final soilsRepositoryProvider = Provider<SoilsRepository>.internal(
  soilsRepository,
  name: r'soilsRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$soilsRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SoilsRepositoryRef = ProviderRef<SoilsRepository>;
String _$soilsNotifierHash() => r'168d1f0b68dba6e4a265c1cdb41e5b180fb36c97';

/// See also [SoilsNotifier].
@ProviderFor(SoilsNotifier)
final soilsNotifierProvider =
    AutoDisposeStreamNotifierProvider<SoilsNotifier, List<SoilModel>>.internal(
  SoilsNotifier.new,
  name: r'soilsNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$soilsNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SoilsNotifier = AutoDisposeStreamNotifier<List<SoilModel>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
