import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/workspaces/domain/workspace_model.dart';
import '../../features/workspaces/presentation/providers/workspace_providers.dart';
import '../database/database_provider.dart';
import '../database/sync_cursors_dao.dart';
import '../storage/photo_storage_provider.dart';
import 'sync_service.dart';
import 'workspace_config_store.dart';

part 'sync_providers.g.dart';

class _RiverpodWorkspaceConfigStore implements WorkspaceConfigStore {
  _RiverpodWorkspaceConfigStore(this._ref, this._workspaceId);

  final Ref _ref;
  final String _workspaceId;

  @override
  Workspace get current =>
      _ref.read(workspacesNotifierProvider.notifier).getById(_workspaceId);

  @override
  Future<void> save(Workspace updated) =>
      _ref.read(workspacesNotifierProvider.notifier).upsert(updated);
}

@Riverpod(keepAlive: true)
SyncService syncService(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  final workspaceId = ref.watch(activeWorkspaceIdNotifierProvider);
  final photoStorage = ref.watch(photoStorageProvider);
  return SyncService(
    db,
    _RiverpodWorkspaceConfigStore(ref, workspaceId),
    photoStorage,
  );
}

/// The push cursor for the 'server' peer, or null when there's no server
/// to compare against (local-only workspace, or never logged in). Entities
/// with `localRev` greater than this haven't been delivered to the server
/// yet -- the basis for every "pending sync" badge in the UI.
@riverpod
Future<int?> pushCursorToServer(Ref ref) async {
  final syncService = ref.watch(syncServiceProvider);
  if (!syncService.isLoggedIn) return null;
  final db = ref.watch(appDatabaseProvider);
  return db.syncCursorsDao.getCursor(syncServerPeerId, syncDirectionPush);
}

@riverpod
Future<int> pendingSyncCount(Ref ref) async {
  final cursor = await ref.watch(pushCursorToServerProvider.future);
  if (cursor == null) return 0;

  final db = ref.watch(appDatabaseProvider);
  const noLimit = 0x7fffffff;
  final counts = await Future.wait([
    db.speciesDao.changesSince(cursor, limit: noLimit),
    db.plantsDao.changesSince(cursor, limit: noLimit),
    db.entriesDao.changesSince(cursor, limit: noLimit),
    db.locationsDao.changesSince(cursor, limit: noLimit),
    db.soilsDao.changesSince(cursor, limit: noLimit),
  ]);
  return counts.fold<int>(0, (sum, list) => sum + list.length);
}

@riverpod
class SyncNotifier extends _$SyncNotifier {
  @override
  AsyncValue<SyncResult?> build() => const AsyncValue.data(null);

  Future<void> sync() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(syncServiceProvider).sync(),
    );
    ref.invalidate(pendingSyncCountProvider);
  }

  Future<void> login(String serverUrl, String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(syncServiceProvider).login(serverUrl, email, password);
      return null;
    });
  }

  Future<void> logout() async {
    await ref.read(syncServiceProvider).logout();
    state = const AsyncValue.data(null);
    ref.invalidate(pendingSyncCountProvider);
  }
}
