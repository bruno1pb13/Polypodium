// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_banner_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Transient top-of-screen banner shown for background sync activity: a
/// green line when new content was pulled down, a red line when a sync
/// attempt couldn't reach the server. Both auto-dismiss after a few
/// seconds -- the app must keep working normally with local data either way.

@ProviderFor(SyncBannerController)
final syncBannerControllerProvider = SyncBannerControllerProvider._();

/// Transient top-of-screen banner shown for background sync activity: a
/// green line when new content was pulled down, a red line when a sync
/// attempt couldn't reach the server. Both auto-dismiss after a few
/// seconds -- the app must keep working normally with local data either way.
final class SyncBannerControllerProvider
    extends $NotifierProvider<SyncBannerController, SyncBannerState?> {
  /// Transient top-of-screen banner shown for background sync activity: a
  /// green line when new content was pulled down, a red line when a sync
  /// attempt couldn't reach the server. Both auto-dismiss after a few
  /// seconds -- the app must keep working normally with local data either way.
  SyncBannerControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'syncBannerControllerProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$syncBannerControllerHash();

  @$internal
  @override
  SyncBannerController create() => SyncBannerController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SyncBannerState? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SyncBannerState?>(value),
    );
  }
}

String _$syncBannerControllerHash() =>
    r'd7ad0b60e5fa383fd7e0ac7f685a50d6c394df1c';

/// Transient top-of-screen banner shown for background sync activity: a
/// green line when new content was pulled down, a red line when a sync
/// attempt couldn't reach the server. Both auto-dismiss after a few
/// seconds -- the app must keep working normally with local data either way.

abstract class _$SyncBannerController extends $Notifier<SyncBannerState?> {
  SyncBannerState? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<SyncBannerState?, SyncBannerState?>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<SyncBannerState?, SyncBannerState?>,
        SyncBannerState?,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}
