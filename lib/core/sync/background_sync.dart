import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/settings/data/settings_repository.dart';
import '../../features/workspaces/data/workspace_repository.dart';
import '../../features/workspaces/domain/workspace_model.dart';
import '../../features/workspaces/domain/workspace_paths.dart';
import '../database/app_database.dart';
import '../storage/photo_storage.dart';
import 'auto_sync_controller.dart' show kSyncIntervalBatterySaverMinutes;
import 'sync_service.dart';
import 'workspace_config_store.dart';

enum BackgroundSyncOutcome { skipped, synced, failed }

/// One best-effort sync pass from the WorkManager isolate, run before the
/// periodic notification reschedule so reminders reflect changes made on
/// other devices and local writes (e.g. "Watered" from a notification) reach
/// the server. Never throws and is bounded by [timeout]: the reschedule that
/// follows must always run.
class BackgroundSync {
  BackgroundSync({
    required Workspace? workspace,
    required SettingsRepository settings,
    required Future<SyncResult> Function() syncPass,
    this.timeout = defaultTimeout,
    this.minInterval = defaultMinInterval,
    DateTime Function()? now,
  })  : _workspace = workspace,
        _settings = settings,
        _syncPass = syncPass,
        _now = now ?? DateTime.now;

  static const defaultTimeout = Duration(seconds: 60);

  /// A pass this recent makes the background one redundant. Longer than the
  /// open app's slowest periodic interval (battery saver), so a background
  /// pass never runs alongside an app that is syncing on its own, whose
  /// Drift streams wouldn't see the rows pulled here until resumed.
  static const defaultMinInterval =
      Duration(minutes: kSyncIntervalBatterySaverMinutes + 5);

  final Workspace? _workspace;
  final SettingsRepository _settings;
  final Future<SyncResult> Function() _syncPass;
  final Duration timeout;
  final Duration minInterval;
  final DateTime Function() _now;

  Future<BackgroundSyncOutcome> run() async {
    final ws = _workspace;
    if (ws == null || !ws.isLoggedIn) return BackgroundSyncOutcome.skipped;
    if (!_settings.isAutoSyncEnabled()) return BackgroundSyncOutcome.skipped;
    final last = ws.lastSyncAt;
    if (last != null && _now().difference(last) < minInterval) {
      return BackgroundSyncOutcome.skipped;
    }

    try {
      // A timed-out pass keeps running unawaited. Cursors only advance past
      // what was applied or delivered, so being cut short just repeats
      // (idempotent) work on the next pass.
      final result = await _syncPass().timeout(timeout);
      // ignore: avoid_print
      print('[BackgroundSync] pulled ${result.pulled}, '
          'pushed ${result.pushed}');
      return BackgroundSyncOutcome.synced;
    } catch (e) {
      // Offline, server down or session expired: the open app surfaces
      // these on its next sync, nothing to persist from here.
      // ignore: avoid_print
      print('[BackgroundSync] failed: $e');
      return BackgroundSyncOutcome.failed;
    }
  }

  /// Production wiring for [db], the active workspace's database opened by
  /// the WorkManager task. Expects SharedPreferences already reloaded.
  static Future<void> runForActiveWorkspace(
      AppDatabase db, Workspace? workspace) async {
    final prefs = await SharedPreferences.getInstance();
    await BackgroundSync(
      workspace: workspace,
      settings: SettingsRepository(prefs),
      syncPass: () => SyncService(
        db,
        PrefsWorkspaceConfigStore(prefs, workspace!.id),
        PhotoStorage(baseDirName: photoDirNameFor(workspace)),
      ).sync(),
    ).run();
  }
}

/// [WorkspaceConfigStore] for isolates without Riverpod, reading straight
/// from SharedPreferences. Sync only ever stamps `lastSyncAt`, so [save]
/// merges just that into a freshly reloaded copy: the UI isolate may have
/// logged out or edited the workspace meanwhile, and a stale snapshot must
/// not overwrite it.
@visibleForTesting
class PrefsWorkspaceConfigStore implements WorkspaceConfigStore {
  PrefsWorkspaceConfigStore(this._prefs, this._workspaceId)
      : _repo = WorkspaceRepository(_prefs);

  final SharedPreferences _prefs;
  final WorkspaceRepository _repo;
  final String _workspaceId;

  @override
  Workspace get current => _repo.loadAll().firstWhere(
        (w) => w.id == _workspaceId,
        orElse: Workspace.newLocal,
      );

  @override
  Future<void> save(Workspace updated) async {
    await _prefs.reload();
    final all = _repo.loadAll();
    if (!all.any((w) => w.id == _workspaceId)) return;
    await _repo.saveAll([
      for (final w in all)
        w.id == _workspaceId ? w.copyWith(lastSyncAt: updated.lastSyncAt) : w,
    ]);
  }
}
