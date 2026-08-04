// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'defensivos_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(defensivosRepository)
final defensivosRepositoryProvider = DefensivosRepositoryProvider._();

final class DefensivosRepositoryProvider extends $FunctionalProvider<
    DefensivosRepository,
    DefensivosRepository,
    DefensivosRepository> with $Provider<DefensivosRepository> {
  DefensivosRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'defensivosRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$defensivosRepositoryHash();

  @$internal
  @override
  $ProviderElement<DefensivosRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DefensivosRepository create(Ref ref) {
    return defensivosRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DefensivosRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DefensivosRepository>(value),
    );
  }
}

String _$defensivosRepositoryHash() =>
    r'3b4e9fe6400ce6ba8bed10c741f9c17bc6935291';

@ProviderFor(DefensivosNotifier)
final defensivosNotifierProvider = DefensivosNotifierProvider._();

final class DefensivosNotifierProvider
    extends $StreamNotifierProvider<DefensivosNotifier, List<DefensivoModel>> {
  DefensivosNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'defensivosNotifierProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$defensivosNotifierHash();

  @$internal
  @override
  DefensivosNotifier create() => DefensivosNotifier();
}

String _$defensivosNotifierHash() =>
    r'89fe2ea8d7685883c2fd86264c32cc91393cbd3c';

abstract class _$DefensivosNotifier
    extends $StreamNotifier<List<DefensivoModel>> {
  Stream<List<DefensivoModel>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref
        as $Ref<AsyncValue<List<DefensivoModel>>, List<DefensivoModel>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<DefensivoModel>>, List<DefensivoModel>>,
        AsyncValue<List<DefensivoModel>>,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}
