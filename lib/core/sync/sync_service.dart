import 'package:uuid/uuid.dart';

import '../../features/plants/data/plants_repository.dart';
import '../../features/workspaces/data/workspace_auth_client.dart';
import '../database/app_database.dart';
import '../notifications/notification_service.dart';
import '../storage/photo_storage.dart';
import 'drift_sync_cursor_store.dart';
import 'drift_sync_storage_adapter.dart';
import 'photo_sync_client.dart';
import 'sync_exceptions.dart';
import 'sync_http_client.dart';
import 'sync_orchestrator.dart';
import 'workspace_config_store.dart';

export 'sync_orchestrator.dart' show SyncProgress, SyncResult, SyncStage;

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
    SyncHttpClient? httpClient,
    INotificationService notifications = const NotificationService(),
    void Function(SyncProgress? progress)? onProgress,
  })  : _authClient = authClient,
        _onProgress = onProgress,
        _plantsRepo = PlantsRepository(db, notifications),
        _orchestrator = SyncOrchestrator(
          storage: DriftSyncStorageAdapter(db),
          cursors: DriftSyncCursorStore(db),
          // A workspace's garden is fixed when it is created, so the clients
          // can carry it instead of every call.
          httpClient:
              httpClient ?? SyncHttpClient(gardenId: _store.current.gardenId),
          photos: PhotoSyncClient(photoStorage,
              gardenId: _store.current.gardenId),
        );

  final WorkspaceConfigStore _store;
  final WorkspaceAuthClient _authClient;
  final SyncOrchestrator _orchestrator;
  final PlantsRepository _plantsRepo;
  final void Function(SyncProgress? progress)? _onProgress;

  Future<SyncResult>? _running;
  bool _rerun = false;

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

  /// Runs one sync at a time: a call while one runs joins it, and gets
  /// one more pass afterwards for whatever it was called for (a local edit
  /// to push, usually). Pulling the same pages twice over is what a big
  /// garden can't afford.
  Future<SyncResult> sync() {
    if (!isLoggedIn) {
      return Future.error(const NotAuthenticatedException());
    }
    final running = _running;
    if (running != null) {
      _rerun = true;
      return running;
    }
    return _running = _syncUntilSettled().whenComplete(() {
      _running = null;
      _onProgress?.call(null);
    });
  }

  Future<SyncResult> _syncUntilSettled() async {
    var pulled = 0;
    var pushed = 0;
    do {
      _rerun = false;
      final result = await _syncOnce();
      pulled += result.pulled;
      pushed += result.pushed;
    } while (_rerun && isLoggedIn);
    return SyncResult(pulled: pulled, pushed: pushed);
  }

  Future<SyncResult> _syncOnce() async {
    final result = await _orchestrator.sync(
      serverUrl: serverUrl!,
      token: token!,
      deviceId: deviceId!,
      onProgress: _onProgress,
    );
    if (result.pulled > 0) {
      // The pull applies remote changes straight to the database, bypassing
      // PlantsRepository — rebuild the reminders so a plant watered or
      // deleted on another device doesn't fire its stale notification here.
      await _plantsRepo.rescheduleNotifications();
    }
    await _store.save(_store.current.copyWith(lastSyncAt: DateTime.now()));
    return result;
  }
}
