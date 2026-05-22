// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entries_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$photoStorageHash() => r'edb77f151a7ffb5671fd4f95d6a089777430e07c';

/// See also [photoStorage].
@ProviderFor(photoStorage)
final photoStorageProvider = Provider<PhotoStorage>.internal(
  photoStorage,
  name: r'photoStorageProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$photoStorageHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PhotoStorageRef = ProviderRef<PhotoStorage>;
String _$entriesRepositoryHash() => r'35059b922e8ea9bf61f58d7693a85f53cbbcb6a6';

/// See also [entriesRepository].
@ProviderFor(entriesRepository)
final entriesRepositoryProvider = Provider<EntriesRepository>.internal(
  entriesRepository,
  name: r'entriesRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$entriesRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef EntriesRepositoryRef = ProviderRef<EntriesRepository>;
String _$entriesNotifierHash() => r'28ff728cd4ab6acc2e2692ceac6576b229530f72';

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

abstract class _$EntriesNotifier
    extends BuildlessAutoDisposeAsyncNotifier<List<EntryModel>> {
  late final String plantId;

  FutureOr<List<EntryModel>> build(
    String plantId,
  );
}

/// See also [EntriesNotifier].
@ProviderFor(EntriesNotifier)
const entriesNotifierProvider = EntriesNotifierFamily();

/// See also [EntriesNotifier].
class EntriesNotifierFamily extends Family<AsyncValue<List<EntryModel>>> {
  /// See also [EntriesNotifier].
  const EntriesNotifierFamily();

  /// See also [EntriesNotifier].
  EntriesNotifierProvider call(
    String plantId,
  ) {
    return EntriesNotifierProvider(
      plantId,
    );
  }

  @override
  EntriesNotifierProvider getProviderOverride(
    covariant EntriesNotifierProvider provider,
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
  String? get name => r'entriesNotifierProvider';
}

/// See also [EntriesNotifier].
class EntriesNotifierProvider extends AutoDisposeAsyncNotifierProviderImpl<
    EntriesNotifier, List<EntryModel>> {
  /// See also [EntriesNotifier].
  EntriesNotifierProvider(
    String plantId,
  ) : this._internal(
          () => EntriesNotifier()..plantId = plantId,
          from: entriesNotifierProvider,
          name: r'entriesNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$entriesNotifierHash,
          dependencies: EntriesNotifierFamily._dependencies,
          allTransitiveDependencies:
              EntriesNotifierFamily._allTransitiveDependencies,
          plantId: plantId,
        );

  EntriesNotifierProvider._internal(
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
  FutureOr<List<EntryModel>> runNotifierBuild(
    covariant EntriesNotifier notifier,
  ) {
    return notifier.build(
      plantId,
    );
  }

  @override
  Override overrideWith(EntriesNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: EntriesNotifierProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<EntriesNotifier, List<EntryModel>>
      createElement() {
    return _EntriesNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is EntriesNotifierProvider && other.plantId == plantId;
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
mixin EntriesNotifierRef
    on AutoDisposeAsyncNotifierProviderRef<List<EntryModel>> {
  /// The parameter `plantId` of this provider.
  String get plantId;
}

class _EntriesNotifierProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<EntriesNotifier,
        List<EntryModel>> with EntriesNotifierRef {
  _EntriesNotifierProviderElement(super.provider);

  @override
  String get plantId => (origin as EntriesNotifierProvider).plantId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
