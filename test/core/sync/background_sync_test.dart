import 'dart:async';
import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:polypodium/core/database/app_database.dart';
import 'package:polypodium/core/database/sync_cursors_dao.dart';
import 'package:polypodium/core/sync/background_sync.dart';
import 'package:polypodium/core/sync/sync_service.dart';
import 'package:polypodium/features/settings/data/settings_repository.dart';
import 'package:polypodium/features/workspaces/domain/workspace_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _now = DateTime(2026, 10, 5, 12);

Workspace _remote({String? token = 'tok', DateTime? lastSyncAt}) => Workspace(
      id: 'remote-1',
      name: 'Server',
      type: WorkspaceType.remote,
      serverUrl: 'https://example.test',
      token: token,
      deviceId: 'dev-1',
      lastSyncAt: lastSyncAt,
      createdAt: DateTime(2026, 1, 1),
    );

Future<SettingsRepository> _settings({bool autoSync = true}) async {
  SharedPreferences.setMockInitialValues({'auto_sync_enabled': autoSync});
  return SettingsRepository(await SharedPreferences.getInstance());
}

void main() {
  group('BackgroundSync.run', () {
    late int calls;

    Future<SyncResult> pass() async {
      calls++;
      return const SyncResult(pulled: 1, pushed: 2);
    }

    setUp(() => calls = 0);

    Future<BackgroundSyncOutcome> run(
      Workspace? workspace, {
      bool autoSync = true,
      Future<SyncResult> Function()? syncPass,
      Duration timeout = BackgroundSync.defaultTimeout,
    }) async =>
        BackgroundSync(
          workspace: workspace,
          settings: await _settings(autoSync: autoSync),
          syncPass: syncPass ?? pass,
          timeout: timeout,
          now: () => _now,
        ).run();

    test('syncs a logged-in remote workspace', () async {
      expect(await run(_remote()), BackgroundSyncOutcome.synced);
      expect(calls, 1);
    });

    test('skips the local workspace', () async {
      expect(await run(Workspace.newLocal()), BackgroundSyncOutcome.skipped);
      expect(await run(null), BackgroundSyncOutcome.skipped);
      expect(calls, 0);
    });

    test('skips a remote workspace without a session', () async {
      expect(await run(_remote(token: null)), BackgroundSyncOutcome.skipped);
      expect(calls, 0);
    });

    test('skips when auto-sync is disabled', () async {
      expect(
          await run(_remote(), autoSync: false), BackgroundSyncOutcome.skipped);
      expect(calls, 0);
    });

    test('skips when the workspace synced recently', () async {
      final recent = _now.subtract(const Duration(minutes: 5));
      expect(await run(_remote(lastSyncAt: recent)),
          BackgroundSyncOutcome.skipped);

      final old = _now.subtract(BackgroundSync.defaultMinInterval);
      expect(await run(_remote(lastSyncAt: old)), BackgroundSyncOutcome.synced);
      expect(calls, 1);
    });

    test('reports a failing pass instead of throwing', () async {
      final outcome = await run(_remote(),
          syncPass: () => Future.error(Exception('offline')));
      expect(outcome, BackgroundSyncOutcome.failed);
    });

    test('gives up on a pass that outlives the timeout', () async {
      final hanging = Completer<SyncResult>();
      final outcome = await run(_remote(),
          syncPass: () => hanging.future,
          timeout: const Duration(milliseconds: 10));
      expect(outcome, BackgroundSyncOutcome.failed);
    });
  });

  group('PrefsWorkspaceConfigStore', () {
    test('save only stamps lastSyncAt onto the current stored workspace',
        () async {
      SharedPreferences.setMockInitialValues({
        'workspaces_v1': jsonEncode([
          Workspace.newLocal().toJson(),
          _remote().toJson(),
        ]),
      });
      final prefs = await SharedPreferences.getInstance();
      final store = PrefsWorkspaceConfigStore(prefs, 'remote-1');
      final snapshot = store.current;
      expect(snapshot.token, 'tok');

      // The UI isolate logs out while the background pass is running.
      await prefs.setString(
        'workspaces_v1',
        jsonEncode([
          Workspace.newLocal().toJson(),
          _remote(token: null).toJson(),
        ]),
      );

      await store.save(snapshot.copyWith(lastSyncAt: _now));

      final saved = store.current;
      expect(saved.token, isNull);
      expect(saved.lastSyncAt, _now);
    });
  });

  group('SyncCursorsDao.setCursor', () {
    test('never moves a cursor backwards', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      final dao = db.syncCursorsDao;

      await dao.setCursor(syncServerPeerId, syncDirectionPull, 200);
      await dao.setCursor(syncServerPeerId, syncDirectionPull, 150);
      expect(await dao.getCursor(syncServerPeerId, syncDirectionPull), 200);

      await dao.setCursor(syncServerPeerId, syncDirectionPull, 250);
      expect(await dao.getCursor(syncServerPeerId, syncDirectionPull), 250);
      expect(await dao.getCursor(syncServerPeerId, syncDirectionPush), 0);
    });
  });
}
