// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'species_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(speciesRepository)
final speciesRepositoryProvider = SpeciesRepositoryProvider._();

final class SpeciesRepositoryProvider extends $FunctionalProvider<
    SpeciesRepository,
    SpeciesRepository,
    SpeciesRepository> with $Provider<SpeciesRepository> {
  SpeciesRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'speciesRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$speciesRepositoryHash();

  @$internal
  @override
  $ProviderElement<SpeciesRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SpeciesRepository create(Ref ref) {
    return speciesRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SpeciesRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SpeciesRepository>(value),
    );
  }
}

String _$speciesRepositoryHash() => r'60c995257591df82175f8a29f0a08cbceedbea0c';

@ProviderFor(SpeciesNotifier)
final speciesNotifierProvider = SpeciesNotifierProvider._();

final class SpeciesNotifierProvider
    extends $StreamNotifierProvider<SpeciesNotifier, List<SpeciesModel>> {
  SpeciesNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'speciesNotifierProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$speciesNotifierHash();

  @$internal
  @override
  SpeciesNotifier create() => SpeciesNotifier();
}

String _$speciesNotifierHash() => r'9c16f8c6f4f92d14dda500f1e63be388814c98c5';

abstract class _$SpeciesNotifier extends $StreamNotifier<List<SpeciesModel>> {
  Stream<List<SpeciesModel>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<SpeciesModel>>, List<SpeciesModel>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<SpeciesModel>>, List<SpeciesModel>>,
        AsyncValue<List<SpeciesModel>>,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}
