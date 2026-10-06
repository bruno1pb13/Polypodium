// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Entries of every plant, newest first.

@ProviderFor(allGardenEntries)
final allGardenEntriesProvider = AllGardenEntriesProvider._();

/// Entries of every plant, newest first.

final class AllGardenEntriesProvider extends $FunctionalProvider<
        AsyncValue<List<EntryModel>>,
        List<EntryModel>,
        Stream<List<EntryModel>>>
    with $FutureModifier<List<EntryModel>>, $StreamProvider<List<EntryModel>> {
  /// Entries of every plant, newest first.
  AllGardenEntriesProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'allGardenEntriesProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$allGardenEntriesHash();

  @$internal
  @override
  $StreamProviderElement<List<EntryModel>> $createElement(
          $ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<EntryModel>> create(Ref ref) {
    return allGardenEntries(ref);
  }
}

String _$allGardenEntriesHash() => r'bce3fd797ae811e50f1b7e018d6e30897409c744';

/// The garden's logging history, rebuilt as plants and entries change.

@ProviderFor(gardenActivity)
final gardenActivityProvider = GardenActivityProvider._();

/// The garden's logging history, rebuilt as plants and entries change.

final class GardenActivityProvider extends $FunctionalProvider<
        AsyncValue<GardenActivity>, GardenActivity, FutureOr<GardenActivity>>
    with $FutureModifier<GardenActivity>, $FutureProvider<GardenActivity> {
  /// The garden's logging history, rebuilt as plants and entries change.
  GardenActivityProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'gardenActivityProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$gardenActivityHash();

  @$internal
  @override
  $FutureProviderElement<GardenActivity> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<GardenActivity> create(Ref ref) {
    return gardenActivity(ref);
  }
}

String _$gardenActivityHash() => r'f04b31a8d631187ed8d4a6f83442ffd10ad7031b';
