// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entry_filters_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$availableEntryTypesHash() =>
    r'b9e23a5368b0fd8b4190e6381ed627093081a6de';

/// See also [availableEntryTypes].
@ProviderFor(availableEntryTypes)
final availableEntryTypesProvider =
    AutoDisposeProvider<List<EntryType>>.internal(
  availableEntryTypes,
  name: r'availableEntryTypesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$availableEntryTypesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AvailableEntryTypesRef = AutoDisposeProviderRef<List<EntryType>>;
String _$entryFiltersNotifierHash() =>
    r'633506304dacb568faf50cfae400a056f7551868';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$EntryFiltersNotifier
    extends BuildlessAutoDisposeNotifier<Set<EntryType>> {
  late final String plantId;

  Set<EntryType> build(
    String plantId,
  );
}

/// See also [EntryFiltersNotifier].
@ProviderFor(EntryFiltersNotifier)
const entryFiltersNotifierProvider = EntryFiltersNotifierFamily();

/// See also [EntryFiltersNotifier].
class EntryFiltersNotifierFamily extends Family<Set<EntryType>> {
  /// See also [EntryFiltersNotifier].
  const EntryFiltersNotifierFamily();

  /// See also [EntryFiltersNotifier].
  EntryFiltersNotifierProvider call(
    String plantId,
  ) {
    return EntryFiltersNotifierProvider(
      plantId,
    );
  }

  @override
  EntryFiltersNotifierProvider getProviderOverride(
    covariant EntryFiltersNotifierProvider provider,
  ) {
    return call(
      provider.plantId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'entryFiltersNotifierProvider';
}

/// See also [EntryFiltersNotifier].
class EntryFiltersNotifierProvider extends AutoDisposeNotifierProviderImpl<
    EntryFiltersNotifier, Set<EntryType>> {
  /// See also [EntryFiltersNotifier].
  EntryFiltersNotifierProvider(
    String plantId,
  ) : this._internal(
          () => EntryFiltersNotifier()..plantId = plantId,
          from: entryFiltersNotifierProvider,
          name: r'entryFiltersNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$entryFiltersNotifierHash,
          dependencies: EntryFiltersNotifierFamily._dependencies,
          allTransitiveDependencies:
              EntryFiltersNotifierFamily._allTransitiveDependencies,
          plantId: plantId,
        );

  EntryFiltersNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.plantId,
  }) : super.internal();

  final String plantId;

  @override
  Set<EntryType> runNotifierBuild(
    covariant EntryFiltersNotifier notifier,
  ) {
    return notifier.build(
      plantId,
    );
  }

  @override
  Override overrideWith(EntryFiltersNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: EntryFiltersNotifierProvider._internal(
        () => create()..plantId = plantId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        plantId: plantId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<EntryFiltersNotifier, Set<EntryType>>
      createElement() {
    return _EntryFiltersNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is EntryFiltersNotifierProvider && other.plantId == plantId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, plantId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin EntryFiltersNotifierRef
    on AutoDisposeNotifierProviderRef<Set<EntryType>> {
  /// The parameter `plantId` of this provider.
  String get plantId;
}

class _EntryFiltersNotifierProviderElement
    extends AutoDisposeNotifierProviderElement<EntryFiltersNotifier,
        Set<EntryType>> with EntryFiltersNotifierRef {
  _EntryFiltersNotifierProviderElement(super.provider);

  @override
  String get plantId => (origin as EntryFiltersNotifierProvider).plantId;
}

String _$entrySortNotifierHash() => r'ce0f5f1d427b45abeed8058d6b8483b4ca890b4d';

abstract class _$EntrySortNotifier
    extends BuildlessAutoDisposeNotifier<EntrySortOption> {
  late final String plantId;

  EntrySortOption build(
    String plantId,
  );
}

/// See also [EntrySortNotifier].
@ProviderFor(EntrySortNotifier)
const entrySortNotifierProvider = EntrySortNotifierFamily();

/// See also [EntrySortNotifier].
class EntrySortNotifierFamily extends Family<EntrySortOption> {
  /// See also [EntrySortNotifier].
  const EntrySortNotifierFamily();

  /// See also [EntrySortNotifier].
  EntrySortNotifierProvider call(
    String plantId,
  ) {
    return EntrySortNotifierProvider(
      plantId,
    );
  }

  @override
  EntrySortNotifierProvider getProviderOverride(
    covariant EntrySortNotifierProvider provider,
  ) {
    return call(
      provider.plantId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'entrySortNotifierProvider';
}

/// See also [EntrySortNotifier].
class EntrySortNotifierProvider extends AutoDisposeNotifierProviderImpl<
    EntrySortNotifier, EntrySortOption> {
  /// See also [EntrySortNotifier].
  EntrySortNotifierProvider(
    String plantId,
  ) : this._internal(
          () => EntrySortNotifier()..plantId = plantId,
          from: entrySortNotifierProvider,
          name: r'entrySortNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$entrySortNotifierHash,
          dependencies: EntrySortNotifierFamily._dependencies,
          allTransitiveDependencies:
              EntrySortNotifierFamily._allTransitiveDependencies,
          plantId: plantId,
        );

  EntrySortNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.plantId,
  }) : super.internal();

  final String plantId;

  @override
  EntrySortOption runNotifierBuild(
    covariant EntrySortNotifier notifier,
  ) {
    return notifier.build(
      plantId,
    );
  }

  @override
  Override overrideWith(EntrySortNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: EntrySortNotifierProvider._internal(
        () => create()..plantId = plantId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        plantId: plantId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<EntrySortNotifier, EntrySortOption>
      createElement() {
    return _EntrySortNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is EntrySortNotifierProvider && other.plantId == plantId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, plantId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin EntrySortNotifierRef on AutoDisposeNotifierProviderRef<EntrySortOption> {
  /// The parameter `plantId` of this provider.
  String get plantId;
}

class _EntrySortNotifierProviderElement
    extends AutoDisposeNotifierProviderElement<EntrySortNotifier,
        EntrySortOption> with EntrySortNotifierRef {
  _EntrySortNotifierProviderElement(super.provider);

  @override
  String get plantId => (origin as EntrySortNotifierProvider).plantId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
