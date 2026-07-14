// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entries_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(entriesRepository)
final entriesRepositoryProvider = EntriesRepositoryProvider._();

final class EntriesRepositoryProvider extends $FunctionalProvider<
    EntriesRepository,
    EntriesRepository,
    EntriesRepository> with $Provider<EntriesRepository> {
  EntriesRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'entriesRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$entriesRepositoryHash();

  @$internal
  @override
  $ProviderElement<EntriesRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  EntriesRepository create(Ref ref) {
    return entriesRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EntriesRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EntriesRepository>(value),
    );
  }
}

String _$entriesRepositoryHash() => r'5cfd89564a430f86edc242884039887e067525d3';

@ProviderFor(entryMutations)
final entryMutationsProvider = EntryMutationsProvider._();

final class EntryMutationsProvider
    extends $FunctionalProvider<EntryMutations, EntryMutations, EntryMutations>
    with $Provider<EntryMutations> {
  EntryMutationsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'entryMutationsProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$entryMutationsHash();

  @$internal
  @override
  $ProviderElement<EntryMutations> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  EntryMutations create(Ref ref) {
    return entryMutations(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EntryMutations value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EntryMutations>(value),
    );
  }
}

String _$entryMutationsHash() => r'b9c58869198d149dbae80ee6d694c81494c7397a';

@ProviderFor(EntriesNotifier)
final entriesNotifierProvider = EntriesNotifierFamily._();

final class EntriesNotifierProvider
    extends $StreamNotifierProvider<EntriesNotifier, List<EntryModel>> {
  EntriesNotifierProvider._(
      {required EntriesNotifierFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'entriesNotifierProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$entriesNotifierHash();

  @override
  String toString() {
    return r'entriesNotifierProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  EntriesNotifier create() => EntriesNotifier();

  @override
  bool operator ==(Object other) {
    return other is EntriesNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$entriesNotifierHash() => r'b96cb47e6a9e1cbc8f35b7b777352abc819a5f0b';

final class EntriesNotifierFamily extends $Family
    with
        $ClassFamilyOverride<EntriesNotifier, AsyncValue<List<EntryModel>>,
            List<EntryModel>, Stream<List<EntryModel>>, String> {
  EntriesNotifierFamily._()
      : super(
          retry: null,
          name: r'entriesNotifierProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  EntriesNotifierProvider call(
    String plantId,
  ) =>
      EntriesNotifierProvider._(argument: plantId, from: this);

  @override
  String toString() => r'entriesNotifierProvider';
}

abstract class _$EntriesNotifier extends $StreamNotifier<List<EntryModel>> {
  late final _$args = ref.$arg as String;
  String get plantId => _$args;

  Stream<List<EntryModel>> build(
    String plantId,
  );
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<EntryModel>>, List<EntryModel>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<EntryModel>>, List<EntryModel>>,
        AsyncValue<List<EntryModel>>,
        Object?,
        Object?>;
    return element.handleCreate(
        ref,
        () => build(
              _$args,
            ));
  }
}
