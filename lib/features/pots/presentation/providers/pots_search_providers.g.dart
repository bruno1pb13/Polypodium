// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pots_search_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PotSearchQuery)
final potSearchQueryProvider = PotSearchQueryProvider._();

final class PotSearchQueryProvider
    extends $NotifierProvider<PotSearchQuery, String> {
  PotSearchQueryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'potSearchQueryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$potSearchQueryHash();

  @$internal
  @override
  PotSearchQuery create() => PotSearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$potSearchQueryHash() => r'af7560361a6ad0c2640cecdc03846e3e1ac9ca11';

abstract class _$PotSearchQuery extends $Notifier<String> {
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

@ProviderFor(PotSortOptionNotifier)
final potSortOptionNotifierProvider = PotSortOptionNotifierProvider._();

final class PotSortOptionNotifierProvider
    extends $NotifierProvider<PotSortOptionNotifier, PotSortOption> {
  PotSortOptionNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'potSortOptionNotifierProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$potSortOptionNotifierHash();

  @$internal
  @override
  PotSortOptionNotifier create() => PotSortOptionNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PotSortOption value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PotSortOption>(value),
    );
  }
}

String _$potSortOptionNotifierHash() =>
    r'c18d83959946389b963b93c554debc8c9bb28d5a';

abstract class _$PotSortOptionNotifier extends $Notifier<PotSortOption> {
  PotSortOption build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<PotSortOption, PotSortOption>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<PotSortOption, PotSortOption>,
        PotSortOption,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(filteredSortedPots)
final filteredSortedPotsProvider = FilteredSortedPotsProvider._();

final class FilteredSortedPotsProvider extends $FunctionalProvider<
        AsyncValue<List<PotWithPlants>>,
        List<PotWithPlants>,
        FutureOr<List<PotWithPlants>>>
    with
        $FutureModifier<List<PotWithPlants>>,
        $FutureProvider<List<PotWithPlants>> {
  FilteredSortedPotsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'filteredSortedPotsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$filteredSortedPotsHash();

  @$internal
  @override
  $FutureProviderElement<List<PotWithPlants>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<PotWithPlants>> create(Ref ref) {
    return filteredSortedPots(ref);
  }
}

String _$filteredSortedPotsHash() =>
    r'0c136d9b799467dc4dd2086da4a2feea6a0832ac';
