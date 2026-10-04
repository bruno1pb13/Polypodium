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

String _$plantsNotifierHash() => r'aff6430dbc3a2839df4d39f57930f51d1fa105f4';

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

String _$plantsWithSpeciesHash() => r'e795b5beadfa93afa9aaecac5c31622a8999d4e8';

/// Survival of the species' plants: every non-deleted plant counts towards
/// [total], and all but the dead ones towards [alive] (donated and archived
/// plants survived, they just left the collection).

@ProviderFor(speciesSurvival)
final speciesSurvivalProvider = SpeciesSurvivalFamily._();

/// Survival of the species' plants: every non-deleted plant counts towards
/// [total], and all but the dead ones towards [alive] (donated and archived
/// plants survived, they just left the collection).

final class SpeciesSurvivalProvider extends $FunctionalProvider<
        AsyncValue<
            ({
              int alive,
              int total,
            })>,
        ({
          int alive,
          int total,
        }),
        FutureOr<
            ({
              int alive,
              int total,
            })>>
    with
        $FutureModifier<
            ({
              int alive,
              int total,
            })>,
        $FutureProvider<
            ({
              int alive,
              int total,
            })> {
  /// Survival of the species' plants: every non-deleted plant counts towards
  /// [total], and all but the dead ones towards [alive] (donated and archived
  /// plants survived, they just left the collection).
  SpeciesSurvivalProvider._(
      {required SpeciesSurvivalFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'speciesSurvivalProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$speciesSurvivalHash();

  @override
  String toString() {
    return r'speciesSurvivalProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<
      ({
        int alive,
        int total,
      })> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<
      ({
        int alive,
        int total,
      })> create(Ref ref) {
    final argument = this.argument as String;
    return speciesSurvival(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SpeciesSurvivalProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$speciesSurvivalHash() => r'a9e45f88c19bf25dc9ac0fc8de56f4e0f6f0cd4b';

/// Survival of the species' plants: every non-deleted plant counts towards
/// [total], and all but the dead ones towards [alive] (donated and archived
/// plants survived, they just left the collection).

final class SpeciesSurvivalFamily extends $Family
    with
        $FunctionalFamilyOverride<
            FutureOr<
                ({
                  int alive,
                  int total,
                })>,
            String> {
  SpeciesSurvivalFamily._()
      : super(
          retry: null,
          name: r'speciesSurvivalProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Survival of the species' plants: every non-deleted plant counts towards
  /// [total], and all but the dead ones towards [alive] (donated and archived
  /// plants survived, they just left the collection).

  SpeciesSurvivalProvider call(
    String speciesId,
  ) =>
      SpeciesSurvivalProvider._(argument: speciesId, from: this);

  @override
  String toString() => r'speciesSurvivalProvider';
}
