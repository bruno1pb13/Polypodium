// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entry_filters_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(EntryFiltersNotifier)
final entryFiltersNotifierProvider = EntryFiltersNotifierFamily._();

final class EntryFiltersNotifierProvider
    extends $NotifierProvider<EntryFiltersNotifier, Set<EntryType>> {
  EntryFiltersNotifierProvider._(
      {required EntryFiltersNotifierFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'entryFiltersNotifierProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$entryFiltersNotifierHash();

  @override
  String toString() {
    return r'entryFiltersNotifierProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  EntryFiltersNotifier create() => EntryFiltersNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<EntryType> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<EntryType>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is EntryFiltersNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$entryFiltersNotifierHash() =>
    r'633506304dacb568faf50cfae400a056f7551868';

final class EntryFiltersNotifierFamily extends $Family
    with
        $ClassFamilyOverride<EntryFiltersNotifier, Set<EntryType>,
            Set<EntryType>, Set<EntryType>, String> {
  EntryFiltersNotifierFamily._()
      : super(
          retry: null,
          name: r'entryFiltersNotifierProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  EntryFiltersNotifierProvider call(
    String plantId,
  ) =>
      EntryFiltersNotifierProvider._(argument: plantId, from: this);

  @override
  String toString() => r'entryFiltersNotifierProvider';
}

abstract class _$EntryFiltersNotifier extends $Notifier<Set<EntryType>> {
  late final _$args = ref.$arg as String;
  String get plantId => _$args;

  Set<EntryType> build(
    String plantId,
  );
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Set<EntryType>, Set<EntryType>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<Set<EntryType>, Set<EntryType>>,
        Set<EntryType>,
        Object?,
        Object?>;
    return element.handleCreate(
        ref,
        () => build(
              _$args,
            ));
  }
}

@ProviderFor(availableEntryTypes)
final availableEntryTypesProvider = AvailableEntryTypesProvider._();

final class AvailableEntryTypesProvider extends $FunctionalProvider<
    List<EntryType>,
    List<EntryType>,
    List<EntryType>> with $Provider<List<EntryType>> {
  AvailableEntryTypesProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'availableEntryTypesProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$availableEntryTypesHash();

  @$internal
  @override
  $ProviderElement<List<EntryType>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<EntryType> create(Ref ref) {
    return availableEntryTypes(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<EntryType> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<EntryType>>(value),
    );
  }
}

String _$availableEntryTypesHash() =>
    r'7ca540c3009a92648a95ea85151615a55b271c97';

@ProviderFor(EntrySortNotifier)
final entrySortNotifierProvider = EntrySortNotifierFamily._();

final class EntrySortNotifierProvider
    extends $NotifierProvider<EntrySortNotifier, EntrySortOption> {
  EntrySortNotifierProvider._(
      {required EntrySortNotifierFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'entrySortNotifierProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$entrySortNotifierHash();

  @override
  String toString() {
    return r'entrySortNotifierProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  EntrySortNotifier create() => EntrySortNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EntrySortOption value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EntrySortOption>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is EntrySortNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$entrySortNotifierHash() => r'ce0f5f1d427b45abeed8058d6b8483b4ca890b4d';

final class EntrySortNotifierFamily extends $Family
    with
        $ClassFamilyOverride<EntrySortNotifier, EntrySortOption,
            EntrySortOption, EntrySortOption, String> {
  EntrySortNotifierFamily._()
      : super(
          retry: null,
          name: r'entrySortNotifierProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  EntrySortNotifierProvider call(
    String plantId,
  ) =>
      EntrySortNotifierProvider._(argument: plantId, from: this);

  @override
  String toString() => r'entrySortNotifierProvider';
}

abstract class _$EntrySortNotifier extends $Notifier<EntrySortOption> {
  late final _$args = ref.$arg as String;
  String get plantId => _$args;

  EntrySortOption build(
    String plantId,
  );
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<EntrySortOption, EntrySortOption>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<EntrySortOption, EntrySortOption>,
        EntrySortOption,
        Object?,
        Object?>;
    return element.handleCreate(
        ref,
        () => build(
              _$args,
            ));
  }
}
