// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'soils_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(soilsRepository)
final soilsRepositoryProvider = SoilsRepositoryProvider._();

final class SoilsRepositoryProvider extends $FunctionalProvider<SoilsRepository,
    SoilsRepository, SoilsRepository> with $Provider<SoilsRepository> {
  SoilsRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'soilsRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$soilsRepositoryHash();

  @$internal
  @override
  $ProviderElement<SoilsRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SoilsRepository create(Ref ref) {
    return soilsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SoilsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SoilsRepository>(value),
    );
  }
}

String _$soilsRepositoryHash() => r'adc2e770e2f6480e6a42f0b0acc7866f11675b53';

@ProviderFor(SoilsNotifier)
final soilsNotifierProvider = SoilsNotifierProvider._();

final class SoilsNotifierProvider
    extends $StreamNotifierProvider<SoilsNotifier, List<SoilModel>> {
  SoilsNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'soilsNotifierProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$soilsNotifierHash();

  @$internal
  @override
  SoilsNotifier create() => SoilsNotifier();
}

String _$soilsNotifierHash() => r'168d1f0b68dba6e4a265c1cdb41e5b180fb36c97';

abstract class _$SoilsNotifier extends $StreamNotifier<List<SoilModel>> {
  Stream<List<SoilModel>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<SoilModel>>, List<SoilModel>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<SoilModel>>, List<SoilModel>>,
        AsyncValue<List<SoilModel>>,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}
