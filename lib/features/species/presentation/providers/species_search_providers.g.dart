// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'species_search_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SpeciesSearchQuery)
final speciesSearchQueryProvider = SpeciesSearchQueryProvider._();

final class SpeciesSearchQueryProvider
    extends $NotifierProvider<SpeciesSearchQuery, String> {
  SpeciesSearchQueryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'speciesSearchQueryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$speciesSearchQueryHash();

  @$internal
  @override
  SpeciesSearchQuery create() => SpeciesSearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$speciesSearchQueryHash() =>
    r'9e73842d1c51d494ffe3b23a8b05b1d6c3d73373';

abstract class _$SpeciesSearchQuery extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<String, String>, String, Object?, Object?>;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(SpeciesSortOptionNotifier)
final speciesSortOptionNotifierProvider = SpeciesSortOptionNotifierProvider._();

final class SpeciesSortOptionNotifierProvider
    extends $NotifierProvider<SpeciesSortOptionNotifier, SpeciesSortOption> {
  SpeciesSortOptionNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'speciesSortOptionNotifierProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$speciesSortOptionNotifierHash();

  @$internal
  @override
  SpeciesSortOptionNotifier create() => SpeciesSortOptionNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SpeciesSortOption value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SpeciesSortOption>(value),
    );
  }
}

String _$speciesSortOptionNotifierHash() =>
    r'f5b9fccf188eb671dee2985db33c3a64991cc8c7';

abstract class _$SpeciesSortOptionNotifier
    extends $Notifier<SpeciesSortOption> {
  SpeciesSortOption build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<SpeciesSortOption, SpeciesSortOption>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<SpeciesSortOption, SpeciesSortOption>,
        SpeciesSortOption,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(filteredSortedSpecies)
final filteredSortedSpeciesProvider = FilteredSortedSpeciesProvider._();

final class FilteredSortedSpeciesProvider extends $FunctionalProvider<
        AsyncValue<List<SpeciesModel>>,
        List<SpeciesModel>,
        FutureOr<List<SpeciesModel>>>
    with
        $FutureModifier<List<SpeciesModel>>,
        $FutureProvider<List<SpeciesModel>> {
  FilteredSortedSpeciesProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'filteredSortedSpeciesProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$filteredSortedSpeciesHash();

  @$internal
  @override
  $FutureProviderElement<List<SpeciesModel>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<SpeciesModel>> create(Ref ref) {
    return filteredSortedSpecies(ref);
  }
}

String _$filteredSortedSpeciesHash() =>
    r'1993c6c67e3f7e74035cc0888af82a013ca0242d';
