import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:polypodium/features/workspaces/data/workspace_repository.dart';
import 'package:polypodium/features/workspaces/domain/workspace_model.dart';
import 'package:polypodium/features/workspaces/domain/workspace_paths.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WorkspaceRepository.ensureBootstrapped', () {
    test('fresh install (no legacy keys) creates only the local workspace',
        () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repo = WorkspaceRepository(prefs);

      expect(repo.needsBootstrap(), isTrue);
      await repo.ensureBootstrapped();

      final workspaces = repo.loadAll();
      expect(workspaces, hasLength(1));
      expect(workspaces.single.id, Workspace.localId);
      expect(workspaces.single.type, WorkspaceType.local);
      expect(repo.loadActiveId(), Workspace.localId);
      expect(repo.needsBootstrap(), isFalse);
    });

    test(
        'upgrade while logged in migrates the existing db to a remote '
        'workspace and creates a fresh empty local one', () async {
      SharedPreferences.setMockInitialValues({
        'sync_token': 'tok123',
        'sync_server_url': 'https://example.com',
        'sync_device_id': 'device-1',
        'sync_cursor': 42,
        'sync_user_email': 'user@example.com',
        'sync_last_at': DateTime(2026, 1, 1).toIso8601String(),
      });
      final prefs = await SharedPreferences.getInstance();
      final repo = WorkspaceRepository(prefs);

      await repo.ensureBootstrapped();

      final workspaces = repo.loadAll();
      expect(workspaces, hasLength(2));

      final local =
          workspaces.firstWhere((w) => w.type == WorkspaceType.local);
      final remote =
          workspaces.firstWhere((w) => w.type == WorkspaceType.remote);

      // The migrated remote keeps pointing at the pre-existing file; the
      // fresh local one does not, so they never collide on disk.
      expect(local.dbFileNameOverride, isNull);
      expect(remote.dbFileNameOverride, legacyDbFileName);
      expect(dbFileNameFor(local), isNot(dbFileNameFor(remote)));

      expect(remote.serverUrl, 'https://example.com');
      expect(remote.token, 'tok123');
      expect(remote.deviceId, 'device-1');
      expect(remote.cursor, 42);
      expect(remote.userEmail, 'user@example.com');
      expect(remote.lastSyncAt, DateTime(2026, 1, 1));
      expect(repo.loadActiveId(), remote.id);

      expect(prefs.containsKey('sync_token'), isFalse);
      expect(prefs.containsKey('sync_server_url'), isFalse);
      expect(prefs.containsKey('sync_device_id'), isFalse);
      expect(prefs.containsKey('sync_cursor'), isFalse);
      expect(prefs.containsKey('sync_user_email'), isFalse);
      expect(prefs.containsKey('sync_last_at'), isFalse);
    });

    test(
        'upgrade with partial legacy keys (no token) is treated as not '
        'logged in — becomes local only', () async {
      SharedPreferences.setMockInitialValues({
        'sync_server_url': 'https://example.com',
      });
      final prefs = await SharedPreferences.getInstance();
      final repo = WorkspaceRepository(prefs);

      await repo.ensureBootstrapped();

      final workspaces = repo.loadAll();
      expect(workspaces, hasLength(1));
      expect(workspaces.single.type, WorkspaceType.local);
      expect(repo.loadActiveId(), Workspace.localId);
    });

    test('is idempotent on a fresh install run twice', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repo = WorkspaceRepository(prefs);

      await repo.ensureBootstrapped();
      final firstRun = repo.loadAll();

      await repo.ensureBootstrapped();
      final secondRun = repo.loadAll();

      expect(secondRun.length, firstRun.length);
      expect(secondRun.single.id, firstRun.single.id);
    });

    test(
        'is idempotent for the logged-in migration path (simulating a '
        'retry after a crash)', () async {
      SharedPreferences.setMockInitialValues({
        'sync_token': 'tok123',
        'sync_server_url': 'https://example.com',
      });
      final prefs = await SharedPreferences.getInstance();
      final repo = WorkspaceRepository(prefs);

      await repo.ensureBootstrapped();
      final firstRun = repo.loadAll();
      final firstActiveId = repo.loadActiveId();

      // A second call must be a no-op: workspaces_v1 already exists.
      await repo.ensureBootstrapped();
      final secondRun = repo.loadAll();

      expect(secondRun.length, firstRun.length);
      expect(repo.loadActiveId(), firstActiveId);
    });
  });
}
