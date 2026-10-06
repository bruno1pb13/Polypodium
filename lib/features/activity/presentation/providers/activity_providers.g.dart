// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// How far back the activity screen looks.

@ProviderFor(ActivityRangeNotifier)
final activityRangeNotifierProvider = ActivityRangeNotifierProvider._();

/// How far back the activity screen looks.
final class ActivityRangeNotifierProvider
    extends $NotifierProvider<ActivityRangeNotifier, ActivityRange> {
  /// How far back the activity screen looks.
  ActivityRangeNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'activityRangeNotifierProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$activityRangeNotifierHash();

  @$internal
  @override
  ActivityRangeNotifier create() => ActivityRangeNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ActivityRange value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ActivityRange>(value),
    );
  }
}

String _$activityRangeNotifierHash() =>
    r'4b14601c00636ae98dba80c104d4b35cb580a43f';

/// How far back the activity screen looks.

abstract class _$ActivityRangeNotifier extends $Notifier<ActivityRange> {
  ActivityRange build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ActivityRange, ActivityRange>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<ActivityRange, ActivityRange>,
        ActivityRange,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}

/// Entries of every plant within the selected range, newest first.

@ProviderFor(gardenEntriesInRange)
final gardenEntriesInRangeProvider = GardenEntriesInRangeProvider._();

/// Entries of every plant within the selected range, newest first.

final class GardenEntriesInRangeProvider extends $FunctionalProvider<
        AsyncValue<List<EntryModel>>,
        List<EntryModel>,
        Stream<List<EntryModel>>>
    with $FutureModifier<List<EntryModel>>, $StreamProvider<List<EntryModel>> {
  /// Entries of every plant within the selected range, newest first.
  GardenEntriesInRangeProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'gardenEntriesInRangeProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$gardenEntriesInRangeHash();

  @$internal
  @override
  $StreamProviderElement<List<EntryModel>> $createElement(
          $ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<EntryModel>> create(Ref ref) {
    return gardenEntriesInRange(ref);
  }
}

String _$gardenEntriesInRangeHash() =>
    r'4fe0976f10eb6012472b7925a9b1f05e79dfbaaf';

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

String _$gardenActivityHash() => r'df1a3f8b1d18fcfe4151ea05cb28e55ad056c4ea';
