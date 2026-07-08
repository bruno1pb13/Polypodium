// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'soils_search_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SoilSearchQuery)
final soilSearchQueryProvider = SoilSearchQueryProvider._();

final class SoilSearchQueryProvider
    extends $NotifierProvider<SoilSearchQuery, String> {
  SoilSearchQueryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'soilSearchQueryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$soilSearchQueryHash();

  @$internal
  @override
  SoilSearchQuery create() => SoilSearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$soilSearchQueryHash() => r'133aa3046b45f7b0b3543600ef989213bb3a926b';

abstract class _$SoilSearchQuery extends $Notifier<String> {
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

@ProviderFor(SoilSortOptionNotifier)
final soilSortOptionNotifierProvider = SoilSortOptionNotifierProvider._();

final class SoilSortOptionNotifierProvider
    extends $NotifierProvider<SoilSortOptionNotifier, SoilSortOption> {
  SoilSortOptionNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'soilSortOptionNotifierProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$soilSortOptionNotifierHash();

  @$internal
  @override
  SoilSortOptionNotifier create() => SoilSortOptionNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SoilSortOption value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SoilSortOption>(value),
    );
  }
}

String _$soilSortOptionNotifierHash() =>
    r'7bba56a23141084cc9d214c94320e896264788da';

abstract class _$SoilSortOptionNotifier extends $Notifier<SoilSortOption> {
  SoilSortOption build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<SoilSortOption, SoilSortOption>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<SoilSortOption, SoilSortOption>,
        SoilSortOption,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(filteredSortedSoils)
final filteredSortedSoilsProvider = FilteredSortedSoilsProvider._();

final class FilteredSortedSoilsProvider extends $FunctionalProvider<
        AsyncValue<List<SoilModel>>, List<SoilModel>, FutureOr<List<SoilModel>>>
    with $FutureModifier<List<SoilModel>>, $FutureProvider<List<SoilModel>> {
  FilteredSortedSoilsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'filteredSortedSoilsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$filteredSortedSoilsHash();

  @$internal
  @override
  $FutureProviderElement<List<SoilModel>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<SoilModel>> create(Ref ref) {
    return filteredSortedSoils(ref);
  }
}

String _$filteredSortedSoilsHash() =>
    r'd9c7c7c86603a0c94b5a9fe9b68c0b0f76ca5f24';
