// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pots_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(potsRepository)
final potsRepositoryProvider = PotsRepositoryProvider._();

final class PotsRepositoryProvider
    extends $FunctionalProvider<PotsRepository, PotsRepository, PotsRepository>
    with $Provider<PotsRepository> {
  PotsRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'potsRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$potsRepositoryHash();

  @$internal
  @override
  $ProviderElement<PotsRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PotsRepository create(Ref ref) {
    return potsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PotsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PotsRepository>(value),
    );
  }
}

String _$potsRepositoryHash() => r'b9f424fed33e555003d0071dd8825db7e71d5415';

@ProviderFor(PotsNotifier)
final potsNotifierProvider = PotsNotifierProvider._();

final class PotsNotifierProvider
    extends $StreamNotifierProvider<PotsNotifier, List<PotModel>> {
  PotsNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'potsNotifierProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$potsNotifierHash();

  @$internal
  @override
  PotsNotifier create() => PotsNotifier();
}

String _$potsNotifierHash() => r'25f719a2d577f050e8a7c5b4187e72ac08256b69';

abstract class _$PotsNotifier extends $StreamNotifier<List<PotModel>> {
  Stream<List<PotModel>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<PotModel>>, List<PotModel>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<PotModel>>, List<PotModel>>,
        AsyncValue<List<PotModel>>,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(potMutations)
final potMutationsProvider = PotMutationsProvider._();

final class PotMutationsProvider
    extends $FunctionalProvider<PotMutations, PotMutations, PotMutations>
    with $Provider<PotMutations> {
  PotMutationsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'potMutationsProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$potMutationsHash();

  @$internal
  @override
  $ProviderElement<PotMutations> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PotMutations create(Ref ref) {
    return potMutations(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PotMutations value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PotMutations>(value),
    );
  }
}

String _$potMutationsHash() => r'a4cf796883f997d1e7406b96c2c6c5ad061e1bcf';

/// Every live pot with its location and plants, ordered by name.

@ProviderFor(potsWithPlants)
final potsWithPlantsProvider = PotsWithPlantsProvider._();

/// Every live pot with its location and plants, ordered by name.

final class PotsWithPlantsProvider extends $FunctionalProvider<
        AsyncValue<List<PotWithPlants>>,
        List<PotWithPlants>,
        FutureOr<List<PotWithPlants>>>
    with
        $FutureModifier<List<PotWithPlants>>,
        $FutureProvider<List<PotWithPlants>> {
  /// Every live pot with its location and plants, ordered by name.
  PotsWithPlantsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'potsWithPlantsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$potsWithPlantsHash();

  @$internal
  @override
  $FutureProviderElement<List<PotWithPlants>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<PotWithPlants>> create(Ref ref) {
    return potsWithPlants(ref);
  }
}

String _$potsWithPlantsHash() => r'04774c82e8c2430a21575497f0f5ba27a69de319';

/// One pot with its plants; null when it doesn't exist or was deleted.

@ProviderFor(potWithPlants)
final potWithPlantsProvider = PotWithPlantsFamily._();

/// One pot with its plants; null when it doesn't exist or was deleted.

final class PotWithPlantsProvider extends $FunctionalProvider<
        AsyncValue<PotWithPlants?>, PotWithPlants?, FutureOr<PotWithPlants?>>
    with $FutureModifier<PotWithPlants?>, $FutureProvider<PotWithPlants?> {
  /// One pot with its plants; null when it doesn't exist or was deleted.
  PotWithPlantsProvider._(
      {required PotWithPlantsFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'potWithPlantsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$potWithPlantsHash();

  @override
  String toString() {
    return r'potWithPlantsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<PotWithPlants?> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<PotWithPlants?> create(Ref ref) {
    final argument = this.argument as String;
    return potWithPlants(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PotWithPlantsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$potWithPlantsHash() => r'46337bcd2e0c7e3f1cbdde2a787632be19ca9bbe';

/// One pot with its plants; null when it doesn't exist or was deleted.

final class PotWithPlantsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<PotWithPlants?>, String> {
  PotWithPlantsFamily._()
      : super(
          retry: null,
          name: r'potWithPlantsProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// One pot with its plants; null when it doesn't exist or was deleted.

  PotWithPlantsProvider call(
    String potId,
  ) =>
      PotWithPlantsProvider._(argument: potId, from: this);

  @override
  String toString() => r'potWithPlantsProvider';
}
