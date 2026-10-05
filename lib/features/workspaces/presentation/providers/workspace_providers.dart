import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../settings/presentation/providers/settings_providers.dart';
import '../../data/garden_client.dart';
import '../../data/workspace_auth_client.dart';
import '../../domain/garden.dart';
import '../../data/workspace_repository.dart';
import '../../domain/workspace_model.dart';
import '../../domain/workspace_paths.dart';

part 'workspace_providers.g.dart';

@Riverpod(keepAlive: true)
WorkspaceRepository workspaceRepository(Ref ref) {
  final prefs = ref.watch(sharedPreferencesProvider).requireValue;
  return WorkspaceRepository(prefs);
}

@Riverpod(keepAlive: true)
class WorkspacesNotifier extends _$WorkspacesNotifier {
  @override
  List<Workspace> build() {
    return ref.watch(workspaceRepositoryProvider).loadAll();
  }

  /// Falls back to the local workspace if [id] isn't found — this can only
  /// happen if the active id points at a workspace that was removed, and the
  /// local workspace is guaranteed to always exist per ensureBootstrapped().
  Workspace getById(String id) => state.firstWhere(
        (w) => w.id == id,
        orElse: () => state.firstWhere((w) => w.id == Workspace.localId),
      );

  Future<void> _persist(List<Workspace> updated) async {
    await ref.read(workspaceRepositoryProvider).saveAll(updated);
    state = updated;
  }

  Future<void> upsert(Workspace workspace) async {
    final updated = [
      for (final w in state) w.id == workspace.id ? workspace : w,
    ];
    if (!updated.any((w) => w.id == workspace.id)) {
      updated.add(workspace);
    }
    await _persist(updated);
  }

  /// Authenticates against [serverUrl] and adds the result as a brand-new
  /// remote workspace, without touching the currently active one.
  ///
  /// When the account belongs to more than its personal garden, [pickGarden]
  /// chooses which one the workspace syncs (null: the personal one). A
  /// server predating gardens, or any failure listing them, means the
  /// personal garden, as before.
  Future<Workspace> createAndLoginRemote({
    required String serverUrl,
    required String email,
    required String password,
    Future<GardenChoice?> Function(List<Garden> gardens)? pickGarden,
    GardenClient gardenClient = const GardenClient(),
  }) async {
    const authClient = WorkspaceAuthClient();
    final result = await authClient.login(
      serverUrl: serverUrl,
      email: email,
      password: password,
      deviceId: const Uuid().v4(),
    );
    GardenChoice? garden;
    if (pickGarden != null) {
      List<Garden> gardens;
      try {
        gardens = await gardenClient.listGardens(
            serverUrl: serverUrl, token: result.token);
      } catch (_) {
        gardens = const [];
      }
      if (gardens.length > 1) garden = await pickGarden(gardens);
    }
    final workspace = Workspace(
      id: const Uuid().v4(),
      name: garden?.name ?? serverUrl,
      gardenId: garden?.id,
      gardenName: garden?.name,
      type: WorkspaceType.remote,
      serverUrl: serverUrl,
      userEmail: email,
      token: result.token,
      deviceId: result.deviceId,
      createdAt: DateTime.now(),
      role: result.role,
    );
    await upsert(workspace);
    return workspace;
  }

  /// Creates the very first account on [serverUrl] and adds the result as a
  /// brand-new remote workspace named [name]. Only meant to be used for a
  /// server that has no accounts yet (see WorkspaceAuthClient.hasUsers).
  Future<Workspace> createAndRegisterRemote({
    required String serverUrl,
    required String name,
    required String email,
    required String password,
  }) async {
    const authClient = WorkspaceAuthClient();
    final result = await authClient.register(
      serverUrl: serverUrl,
      email: email,
      password: password,
    );
    final workspace = Workspace(
      id: const Uuid().v4(),
      name: name,
      type: WorkspaceType.remote,
      serverUrl: serverUrl,
      userEmail: email,
      token: result.token,
      deviceId: result.deviceId,
      createdAt: DateTime.now(),
      role: result.role,
    );
    await upsert(workspace);
    return workspace;
  }

  /// Opens [garden] in its own workspace, reusing [from]'s server session
  /// (same account and device), and makes it active. A workspace already
  /// syncing that garden is reused instead of duplicated; its database starts
  /// empty otherwise and fills on the first sync.
  Future<Workspace> openGardenWorkspace(
      Workspace from, GardenChoice? garden) async {
    final existing = state.where((w) =>
        w.type == WorkspaceType.remote &&
        w.serverUrl == from.serverUrl &&
        w.userEmail == from.userEmail &&
        w.gardenId == garden?.id);
    final workspace = existing.isNotEmpty
        ? existing.first
        : Workspace(
            id: const Uuid().v4(),
            name: garden?.name ?? from.serverUrl ?? from.name,
            type: WorkspaceType.remote,
            serverUrl: from.serverUrl,
            userEmail: from.userEmail,
            token: from.token,
            deviceId: from.deviceId,
            createdAt: DateTime.now(),
            role: from.role,
            gardenId: garden?.id,
            gardenName: garden?.name,
          );
    if (existing.isEmpty) await upsert(workspace);
    await ref
        .read(activeWorkspaceIdNotifierProvider.notifier)
        .setActive(workspace.id);
    return workspace;
  }

  /// Re-authenticates a previously disconnected remote workspace, keeping its
  /// existing id/name/serverUrl/deviceId (and therefore its database file).
  Future<void> reconnectRemote(String id, String password) async {
    final ws = getById(id);
    if (ws.serverUrl == null || ws.userEmail == null) {
      throw StateError('Workspace sem servidor ou e-mail configurado');
    }
    const authClient = WorkspaceAuthClient();
    final result = await authClient.login(
      serverUrl: ws.serverUrl!,
      email: ws.userEmail!,
      password: password,
      deviceId: ws.deviceId ?? const Uuid().v4(),
    );
    await upsert(ws.copyWith(
      token: result.token,
      deviceId: result.deviceId,
      role: result.role,
    ));
  }

  /// Clears session credentials but keeps the workspace (and its data) —
  /// the counterpart of removeRemote, which deletes both.
  Future<void> logoutRemote(String id) async {
    await upsert(getById(id).disconnected());
  }

  Future<void> rename(String id, String name) async {
    await upsert(getById(id).copyWith(name: name));
  }

  /// Removes a remote workspace's metadata and deletes its on-disk database
  /// and photos. If it's the active workspace, switches to local first so
  /// the file isn't deleted while still open.
  Future<void> removeRemote(String id) async {
    final workspace = state.firstWhere((w) => w.id == id);
    if (workspace.type != WorkspaceType.remote) {
      throw StateError('The local workspace cannot be deleted');
    }

    if (ref.read(activeWorkspaceIdNotifierProvider) == id) {
      await ref
          .read(activeWorkspaceIdNotifierProvider.notifier)
          .setActive(Workspace.localId);
    }

    await _persist([
      for (final w in state)
        if (w.id != id) w,
    ]);
    await _deleteWorkspaceStorage(workspace);
  }

  Future<void> _deleteWorkspaceStorage(Workspace workspace) async {
    final dir = await getApplicationDocumentsDirectory();
    final targets = <FileSystemEntity>[
      File(p.join(dir.path, dbFileNameFor(workspace))),
      Directory(p.join(dir.path, photoDirNameFor(workspace))),
    ];
    for (final target in targets) {
      for (var attempt = 0; attempt < 3; attempt++) {
        try {
          if (await target.exists()) {
            await target.delete(recursive: true);
          }
          break;
        } catch (_) {
          // The OS may hold the handle open briefly after the database
          // connection closes. A leftover file is recoverable manually;
          // blocking the user's delete action on it is worse.
          if (attempt == 2) break;
          await Future.delayed(Duration(milliseconds: 200 * (attempt + 1)));
        }
      }
    }
  }
}

@Riverpod(keepAlive: true)
class ActiveWorkspaceIdNotifier extends _$ActiveWorkspaceIdNotifier {
  @override
  String build() => ref.watch(workspaceRepositoryProvider).loadActiveId();

  Future<void> setActive(String workspaceId) async {
    await ref.read(workspaceRepositoryProvider).saveActiveId(workspaceId);
    state = workspaceId;
  }
}

@riverpod
Workspace activeWorkspace(Ref ref) {
  final id = ref.watch(activeWorkspaceIdNotifierProvider);
  return ref.watch(workspacesNotifierProvider.notifier).getById(id);
}
