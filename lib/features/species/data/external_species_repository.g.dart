// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'external_species_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ExternalSpeciesRepository)
final externalSpeciesRepositoryProvider = ExternalSpeciesRepositoryProvider._();

final class ExternalSpeciesRepositoryProvider
    extends $AsyncNotifierProvider<ExternalSpeciesRepository, void> {
  ExternalSpeciesRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'externalSpeciesRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$externalSpeciesRepositoryHash();

  @$internal
  @override
  ExternalSpeciesRepository create() => ExternalSpeciesRepository();
}

String _$externalSpeciesRepositoryHash() =>
    r'91b912d00e35264c4ae913ff77c3071ade9c4856';

abstract class _$ExternalSpeciesRepository extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<void>, void>,
        AsyncValue<void>,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}
