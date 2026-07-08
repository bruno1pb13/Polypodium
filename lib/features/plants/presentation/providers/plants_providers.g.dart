// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plants_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(plantsRepository)
final plantsRepositoryProvider = PlantsRepositoryProvider._();

final class PlantsRepositoryProvider extends $FunctionalProvider<
    PlantsRepository,
    PlantsRepository,
    PlantsRepository> with $Provider<PlantsRepository> {
  PlantsRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'plantsRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$plantsRepositoryHash();

  @$internal
  @override
  $ProviderElement<PlantsRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PlantsRepository create(Ref ref) {
    return plantsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlantsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlantsRepository>(value),
    );
  }
}

String _$plantsRepositoryHash() => r'801f9b8b0100179effd42508163272755f4d881e';

@ProviderFor(PlantsNotifier)
final plantsNotifierProvider = PlantsNotifierProvider._();

final class PlantsNotifierProvider
    extends $StreamNotifierProvider<PlantsNotifier, List<PlantModel>> {
  PlantsNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'plantsNotifierProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$plantsNotifierHash();

  @$internal
  @override
  PlantsNotifier create() => PlantsNotifier();
}

String _$plantsNotifierHash() => r'21343988b9c33a6853580b3d5e4f5d29f9e5ff33';

abstract class _$PlantsNotifier extends $StreamNotifier<List<PlantModel>> {
  Stream<List<PlantModel>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<PlantModel>>, List<PlantModel>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<PlantModel>>, List<PlantModel>>,
        AsyncValue<List<PlantModel>>,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}

/// Combines each plant with its resolved species for home-screen display.

@ProviderFor(plantsWithSpecies)
final plantsWithSpeciesProvider = PlantsWithSpeciesProvider._();

/// Combines each plant with its resolved species for home-screen display.

final class PlantsWithSpeciesProvider extends $FunctionalProvider<
        AsyncValue<List<PlantWithSpecies>>,
        List<PlantWithSpecies>,
        FutureOr<List<PlantWithSpecies>>>
    with
        $FutureModifier<List<PlantWithSpecies>>,
        $FutureProvider<List<PlantWithSpecies>> {
  /// Combines each plant with its resolved species for home-screen display.
  PlantsWithSpeciesProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'plantsWithSpeciesProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$plantsWithSpeciesHash();

  @$internal
  @override
  $FutureProviderElement<List<PlantWithSpecies>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<PlantWithSpecies>> create(Ref ref) {
    return plantsWithSpecies(ref);
  }
}

String _$plantsWithSpeciesHash() => r'76c78ecd5a93a2705f04e3620e95fd589efd5617';
