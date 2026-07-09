import 'package:uuid/uuid.dart';

import '../../features/workspaces/data/workspace_auth_client.dart';
import '../database/app_database.dart';
import '../storage/photo_storage.dart';
import 'drift_sync_cursor_store.dart';
import 'drift_sync_storage_adapter.dart';
import 'photo_sync_client.dart';
import 'sync_http_client.dart';
import 'sync_orchestrator.dart';
import 'workspace_config_store.dart';

export 'sync_orchestrator.dart' show SyncResult;

/// Thin facade over the sync module: owns login/session state (delegated to
/// [WorkspaceConfigStore]) and wires up [SyncOrchestrator] with this
/// workspace's concrete Drift/HTTP/photo dependencies. Kept separate from
/// SyncOrchestrator itself so Riverpod call sites (sync_providers.dart)
/// don't need to change when the sync protocol's internals do.
class SyncService {
  SyncService(
    AppDatabase db,
    this._store,
    PhotoStorage photoStorage, {
    WorkspaceAuthClient authClient = const WorkspaceAuthClient(),
    SyncHttpClient httpClient = const SyncHttpClient(),
  })  : _authClient = authClient,
        _orchestrator = SyncOrchestrator(
          storage: DriftSyncStorageAdapter(db),
          cursors: DriftSyncCursorStore(db),
          httpClient: httpClient,
          photos: PhotoSyncClient(photoStorage),
        );

  final WorkspaceConfigStore _store;
  final WorkspaceAuthClient _authClient;
  final SyncOrchestrator _orchestrator;

  String? get token => _store.current.token;
  String? get deviceId => _store.current.deviceId;
  String? get serverUrl => _store.current.serverUrl;
  String? get userEmail => _store.current.userEmail;
  bool get isLoggedIn => _store.current.isLoggedIn;
  DateTime? get lastSyncAt => _store.current.lastSyncAt;

  Future<void> checkServer(String serverUrl) =>
      _authClient.checkServer(serverUrl);

  Future<void> login(String serverUrl, String email, String password) async {
    final id = deviceId ?? const Uuid().v4();
    final result = await _authClient.login(
      serverUrl: serverUrl,
      email: email,
      password: password,
      deviceId: id,
    );
    await _store.save(_store.current.copyWith(
      token: result.token,
      deviceId: result.deviceId,
      serverUrl: serverUrl,
      userEmail: email,
    ));
  }

  Future<void> logout() async {
    await _store.save(_store.current.disconnected());
  }

  Future<SyncResult> sync() async {
    if (!isLoggedIn) throw Exception('Não autenticado');
    final result = await _orchestrator.sync(
      serverUrl: serverUrl!,
      token: token!,
      deviceId: deviceId!,
    );
    await _store.save(_store.current.copyWith(lastSyncAt: DateTime.now()));
    return result;
  }
}
