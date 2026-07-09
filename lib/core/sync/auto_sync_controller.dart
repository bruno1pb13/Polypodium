import 'dart:async';
import 'dart:io' show Platform;

import 'package:battery_plus/battery_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/settings/presentation/providers/settings_providers.dart';
import '../../features/workspaces/presentation/providers/workspace_providers.dart';
import 'sync_banner_controller.dart';
import 'sync_providers.dart';

part 'auto_sync_controller.g.dart';

const kSyncIntervalNormalMinutes = 5;
const kSyncIntervalBatterySaverMinutes = 30;

/// Drives periodic background sync while the app is open. Ticks every
/// minute and syncs once the elapsed time reaches the current interval --
/// 5 min normally, 30 min when Android reports the OS battery saver is on
/// (checked fresh on every tick, so it reacts without needing a Timer
/// reschedule). [syncNow] lets app-open and pull-to-refresh trigger the same
/// path/banner feedback; the manual "Sincronizar Agora" button in Settings
/// goes through [syncNotifierProvider] instead, since it has its own
/// loading/error UI.
@Riverpod(keepAlive: true)
class AutoSyncController extends _$AutoSyncController {
  Timer? _ticker;
  int _elapsedMinutes = 0;
  static const _tickInterval = Duration(minutes: 1);
  static final _battery = Battery();

  @override
  void build() {
    ref.onDispose(() => _ticker?.cancel());

    final enabled = ref.watch(autoSyncEnabledNotifierProvider);
    _ticker?.cancel();
    _elapsedMinutes = 0;
    if (enabled) {
      _ticker = Timer.periodic(_tickInterval, (_) => _onTick());
    }
  }

  Future<void> _onTick() async {
    _elapsedMinutes++;
    final interval = await _currentIntervalMinutes();
    if (_elapsedMinutes >= interval) {
      await syncNow();
    }
  }

  Future<int> _currentIntervalMinutes() async {
    if (!Platform.isAndroid) return kSyncIntervalNormalMinutes;
    try {
      final saving = await _battery.isInBatterySaveMode;
      return saving
          ? kSyncIntervalBatterySaverMinutes
          : kSyncIntervalNormalMinutes;
    } catch (_) {
      return kSyncIntervalNormalMinutes;
    }
  }

  /// Silent sync: no loading state, feedback is limited to the top banner
  /// (new content downloaded, or offline) so it never blocks the UI.
  Future<void> syncNow() async {
    _elapsedMinutes = 0;

    final workspace = ref.read(activeWorkspaceProvider);
    if (!workspace.isLoggedIn) return;

    try {
      final result = await ref.read(syncServiceProvider).sync();
      ref.invalidate(pendingSyncCountProvider);
      if (result.pulled > 0) {
        ref
            .read(syncBannerControllerProvider.notifier)
            .showDownloaded(result.pulled);
      }
    } catch (_) {
      ref.read(syncBannerControllerProvider.notifier).showOffline();
    }
  }
}
