// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'defensivos_search_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DefensivoSearchQuery)
final defensivoSearchQueryProvider = DefensivoSearchQueryProvider._();

final class DefensivoSearchQueryProvider
    extends $NotifierProvider<DefensivoSearchQuery, String> {
  DefensivoSearchQueryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'defensivoSearchQueryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$defensivoSearchQueryHash();

  @$internal
  @override
  DefensivoSearchQuery create() => DefensivoSearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$defensivoSearchQueryHash() =>
    r'96a22b4dcc84fe747ca6d04db4db0598bb0eda04';

abstract class _$DefensivoSearchQuery extends $Notifier<String> {
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

@ProviderFor(DefensivoSortOptionNotifier)
final defensivoSortOptionNotifierProvider =
    DefensivoSortOptionNotifierProvider._();

final class DefensivoSortOptionNotifierProvider extends $NotifierProvider<
    DefensivoSortOptionNotifier, DefensivoSortOption> {
  DefensivoSortOptionNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'defensivoSortOptionNotifierProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$defensivoSortOptionNotifierHash();

  @$internal
  @override
  DefensivoSortOptionNotifier create() => DefensivoSortOptionNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DefensivoSortOption value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DefensivoSortOption>(value),
    );
  }
}

String _$defensivoSortOptionNotifierHash() =>
    r'6865a3b897f5506f32e8c08173a66cd132c0442e';

abstract class _$DefensivoSortOptionNotifier
    extends $Notifier<DefensivoSortOption> {
  DefensivoSortOption build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<DefensivoSortOption, DefensivoSortOption>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<DefensivoSortOption, DefensivoSortOption>,
        DefensivoSortOption,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(filteredSortedDefensivos)
final filteredSortedDefensivosProvider = FilteredSortedDefensivosProvider._();

final class FilteredSortedDefensivosProvider extends $FunctionalProvider<
        AsyncValue<List<DefensivoModel>>,
        List<DefensivoModel>,
        FutureOr<List<DefensivoModel>>>
    with
        $FutureModifier<List<DefensivoModel>>,
        $FutureProvider<List<DefensivoModel>> {
  FilteredSortedDefensivosProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'filteredSortedDefensivosProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$filteredSortedDefensivosHash();

  @$internal
  @override
  $FutureProviderElement<List<DefensivoModel>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<DefensivoModel>> create(Ref ref) {
    return filteredSortedDefensivos(ref);
  }
}

String _$filteredSortedDefensivosHash() =>
    r'b6795bc8cc50d9db7702abf3bde83d6bb283c8d7';
