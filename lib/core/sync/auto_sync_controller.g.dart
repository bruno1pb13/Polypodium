// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auto_sync_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Drives periodic background sync while the app is open. Ticks every
/// minute and syncs once the elapsed time reaches the current interval --
/// 5 min normally, 30 min when Android reports the OS battery saver is on
/// (checked fresh on every tick, so it reacts without needing a Timer
/// reschedule). [syncNow] lets app-open and pull-to-refresh trigger the same
/// path/banner feedback; the manual "Sincronizar Agora" button in Settings
/// goes through [syncNotifierProvider] instead, since it has its own
/// loading/error UI.

@ProviderFor(AutoSyncController)
final autoSyncControllerProvider = AutoSyncControllerProvider._();

/// Drives periodic background sync while the app is open. Ticks every
/// minute and syncs once the elapsed time reaches the current interval --
/// 5 min normally, 30 min when Android reports the OS battery saver is on
/// (checked fresh on every tick, so it reacts without needing a Timer
/// reschedule). [syncNow] lets app-open and pull-to-refresh trigger the same
/// path/banner feedback; the manual "Sincronizar Agora" button in Settings
/// goes through [syncNotifierProvider] instead, since it has its own
/// loading/error UI.
final class AutoSyncControllerProvider
    extends $NotifierProvider<AutoSyncController, void> {
  /// Drives periodic background sync while the app is open. Ticks every
  /// minute and syncs once the elapsed time reaches the current interval --
  /// 5 min normally, 30 min when Android reports the OS battery saver is on
  /// (checked fresh on every tick, so it reacts without needing a Timer
  /// reschedule). [syncNow] lets app-open and pull-to-refresh trigger the same
  /// path/banner feedback; the manual "Sincronizar Agora" button in Settings
  /// goes through [syncNotifierProvider] instead, since it has its own
  /// loading/error UI.
  AutoSyncControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'autoSyncControllerProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$autoSyncControllerHash();

  @$internal
  @override
  AutoSyncController create() => AutoSyncController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$autoSyncControllerHash() =>
    r'f31671104d8eae3746f1c9d5c5b34e8804d390f7';

/// Drives periodic background sync while the app is open. Ticks every
/// minute and syncs once the elapsed time reaches the current interval --
/// 5 min normally, 30 min when Android reports the OS battery saver is on
/// (checked fresh on every tick, so it reacts without needing a Timer
/// reschedule). [syncNow] lets app-open and pull-to-refresh trigger the same
/// path/banner feedback; the manual "Sincronizar Agora" button in Settings
/// goes through [syncNotifierProvider] instead, since it has its own
/// loading/error UI.

abstract class _$AutoSyncController extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<void, void>, void, Object?, Object?>;
    return element.handleCreate(ref, build);
  }
}
