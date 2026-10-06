// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Pest and chlorosis entries of every plant, to tell which are active.

@ProviderFor(gardenConditionEntries)
final gardenConditionEntriesProvider = GardenConditionEntriesProvider._();

/// Pest and chlorosis entries of every plant, to tell which are active.

final class GardenConditionEntriesProvider extends $FunctionalProvider<
        AsyncValue<List<EntryModel>>,
        List<EntryModel>,
        Stream<List<EntryModel>>>
    with $FutureModifier<List<EntryModel>>, $StreamProvider<List<EntryModel>> {
  /// Pest and chlorosis entries of every plant, to tell which are active.
  GardenConditionEntriesProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'gardenConditionEntriesProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$gardenConditionEntriesHash();

  @$internal
  @override
  $StreamProviderElement<List<EntryModel>> $createElement(
          $ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<EntryModel>> create(Ref ref) {
    return gardenConditionEntries(ref);
  }
}

String _$gardenConditionEntriesHash() =>
    r'f4d3e1b9ef63d4f3e48584918ad6dbee6b53e377';

/// Everything the home dashboard shows, rebuilt as plants, reminders and
/// entries change.

@ProviderFor(gardenOverview)
final gardenOverviewProvider = GardenOverviewProvider._();

/// Everything the home dashboard shows, rebuilt as plants, reminders and
/// entries change.

final class GardenOverviewProvider extends $FunctionalProvider<
        AsyncValue<GardenOverview>, GardenOverview, FutureOr<GardenOverview>>
    with $FutureModifier<GardenOverview>, $FutureProvider<GardenOverview> {
  /// Everything the home dashboard shows, rebuilt as plants, reminders and
  /// entries change.
  GardenOverviewProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'gardenOverviewProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$gardenOverviewHash();

  @$internal
  @override
  $FutureProviderElement<GardenOverview> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<GardenOverview> create(Ref ref) {
    return gardenOverview(ref);
  }
}

String _$gardenOverviewHash() => r'd24f8c36240c846108ab4a8da6a9b6e21eb114dd';
