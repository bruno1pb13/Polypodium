import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../domain/workspace_model.dart';
import '../domain/workspace_paths.dart';

/// Persists the list of workspaces and which one is active. Metadata is
/// stored as a single serialized JSON list under one key (plus one key for
/// the active id) rather than a Drift table, since it's the same kind of
/// small config that already lived in SharedPreferences before workspaces
/// existed — no relational data, no need for a second database file.
class WorkspaceRepository {
  WorkspaceRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _workspacesKey = 'workspaces_v1';
  static const _activeWorkspaceIdKey = 'active_workspace_id';

  // Legacy single-server SyncService keys, read once during migration then
  // cleared. See sync_service.dart (pre-workspaces) for their original use.
  static const _legacyTokenKey = 'sync_token';
  static const _legacyDeviceIdKey = 'sync_device_id';
  static const _legacyCursorKey = 'sync_cursor';
  static const _legacyServerUrlKey = 'sync_server_url';
  static const _legacyLastSyncAtKey = 'sync_last_at';
  static const _legacyUserEmailKey = 'sync_user_email';

  bool needsBootstrap() => !_prefs.containsKey(_workspacesKey);

  List<Workspace> loadAll() {
    final raw = _prefs.getString(_workspacesKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => Workspace.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveAll(List<Workspace> workspaces) async {
    final raw = jsonEncode(workspaces.map((w) => w.toJson()).toList());
    await _prefs.setString(_workspacesKey, raw);
  }

  String loadActiveId() =>
      _prefs.getString(_activeWorkspaceIdKey) ?? Workspace.localId;

  Future<void> saveActiveId(String id) async {
    await _prefs.setString(_activeWorkspaceIdKey, id);
  }

  /// One-time migration from the pre-workspaces single-server model.
  ///
  /// If the app was already logged into a server, that data was living in
  /// the single `polypodium.db` file, so it becomes a *remote* workspace
  /// (dbFileNameOverride keeps it pointing at that same file, untouched) and
  /// a brand-new empty local workspace is created alongside it. Otherwise
  /// the existing file simply becomes the local workspace. No file is ever
  /// moved, copied, or deleted here — only new metadata is written, and the
  /// legacy keys are cleared last so a crash mid-migration is safely retried
  /// from scratch on the next boot.
  Future<void> ensureBootstrapped() async {
    if (!needsBootstrap()) return;

    final legacyToken = _prefs.getString(_legacyTokenKey);
    final legacyServerUrl = _prefs.getString(_legacyServerUrlKey);
    final wasLoggedIn = legacyToken != null && legacyServerUrl != null;

    final now = DateTime.now();
    late final List<Workspace> workspaces;
    late final String activeId;

    if (wasLoggedIn) {
      final migratedRemote = Workspace(
        id: const Uuid().v4(),
        name: legacyServerUrl,
        type: WorkspaceType.remote,
        serverUrl: legacyServerUrl,
        userEmail: _prefs.getString(_legacyUserEmailKey),
        token: legacyToken,
        deviceId: _prefs.getString(_legacyDeviceIdKey),
        cursor: _prefs.getInt(_legacyCursorKey) ?? 0,
        lastSyncAt:
            DateTime.tryParse(_prefs.getString(_legacyLastSyncAtKey) ?? ''),
        createdAt: now,
        dbFileNameOverride: legacyDbFileName,
      );
      final freshLocal = Workspace(
        id: Workspace.localId,
        name: 'Local',
        type: WorkspaceType.local,
        createdAt: now,
      );
      workspaces = [freshLocal, migratedRemote];
      activeId = migratedRemote.id;
    } else {
      final local = Workspace(
        id: Workspace.localId,
        name: 'Local',
        type: WorkspaceType.local,
        createdAt: now,
        dbFileNameOverride: legacyDbFileName,
      );
      workspaces = [local];
      activeId = Workspace.localId;
    }

    await saveAll(workspaces);
    await saveActiveId(activeId);

    await _prefs.remove(_legacyTokenKey);
    await _prefs.remove(_legacyDeviceIdKey);
    await _prefs.remove(_legacyCursorKey);
    await _prefs.remove(_legacyServerUrlKey);
    await _prefs.remove(_legacyLastSyncAtKey);
    await _prefs.remove(_legacyUserEmailKey);
  }
}
