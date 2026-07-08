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

String _$entriesNotifierHash() => r'21449b8df65eae3ea8f712975c7606233011cb6c';

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
