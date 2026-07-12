// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plant_detail_view_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Which view of the plant detail screen is active (diary/charts/photos).

@ProviderFor(PlantDetailViewNotifier)
final plantDetailViewNotifierProvider = PlantDetailViewNotifierFamily._();

/// Which view of the plant detail screen is active (diary/charts/photos).
final class PlantDetailViewNotifierProvider
    extends $NotifierProvider<PlantDetailViewNotifier, PlantDetailView> {
  /// Which view of the plant detail screen is active (diary/charts/photos).
  PlantDetailViewNotifierProvider._(
      {required PlantDetailViewNotifierFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'plantDetailViewNotifierProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$plantDetailViewNotifierHash();

  @override
  String toString() {
    return r'plantDetailViewNotifierProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  PlantDetailViewNotifier create() => PlantDetailViewNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlantDetailView value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlantDetailView>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PlantDetailViewNotifierProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$plantDetailViewNotifierHash() =>
    r'4af9606f92553b2f4e7e1fd8fe62e11ea5ecff41';

/// Which view of the plant detail screen is active (diary/charts/photos).

final class PlantDetailViewNotifierFamily extends $Family
    with
        $ClassFamilyOverride<PlantDetailViewNotifier, PlantDetailView,
            PlantDetailView, PlantDetailView, String> {
  PlantDetailViewNotifierFamily._()
      : super(
          retry: null,
          name: r'plantDetailViewNotifierProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Which view of the plant detail screen is active (diary/charts/photos).

  PlantDetailViewNotifierProvider call(
    String plantId,
  ) =>
      PlantDetailViewNotifierProvider._(argument: plantId, from: this);

  @override
  String toString() => r'plantDetailViewNotifierProvider';
}

/// Which view of the plant detail screen is active (diary/charts/photos).

abstract class _$PlantDetailViewNotifier extends $Notifier<PlantDetailView> {
  late final _$args = ref.$arg as String;
  String get plantId => _$args;

  PlantDetailView build(
    String plantId,
  );
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<PlantDetailView, PlantDetailView>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<PlantDetailView, PlantDetailView>,
        PlantDetailView,
        Object?,
        Object?>;
    return element.handleCreate(
        ref,
        () => build(
              _$args,
            ));
  }
}
