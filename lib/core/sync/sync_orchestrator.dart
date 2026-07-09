import '../database/sync_cursors_dao.dart' show syncServerPeerId;
import 'i_sync_cursor_store.dart';
import 'i_sync_storage_adapter.dart';
import 'models/entity_change.dart';
import 'photo_sync_client.dart';
import 'sync_http_client.dart';

class SyncResult {
  final int pulled;
  final int pushed;
  const SyncResult({required this.pulled, required this.pushed});
}

/// Orchestrates a full sync cycle against one peer (today: always "the
/// server", identified by [_serverPeerId] -- a future LAN peer would reuse
/// the same orchestrator against a different peer id/URL). Depends only on
/// the storage/cursor/transport abstractions, never on Drift or `http`
/// directly, so each side can be swapped/tested independently.
class SyncOrchestrator {
  SyncOrchestrator({
    required ISyncStorageAdapter storage,
    required ISyncCursorStore cursors,
    required SyncHttpClient httpClient,
    required PhotoSyncClient photos,
  })  : _storage = storage,
        _cursors = cursors,
        _http = httpClient,
        _photos = photos;

  final ISyncStorageAdapter _storage;
  final ISyncCursorStore _cursors;
  final SyncHttpClient _http;
  final PhotoSyncClient _photos;

  static const _serverPeerId = syncServerPeerId;
  static const _pageSize = 100;

  Future<SyncResult> sync({
    required String serverUrl,
    required String token,
    required String deviceId,
  }) async {
    final pulled = await _pull(
        serverUrl: serverUrl, token: token, deviceId: deviceId);
    final pushed = await _push(
        serverUrl: serverUrl, token: token, deviceId: deviceId);
    return SyncResult(pulled: pulled, pushed: pushed);
  }

  // -- pull: real GET, applies the server's changes locally ------------------

  Future<int> _pull({
    required String serverUrl,
    required String token,
    required String deviceId,
  }) async {
    var total = 0;
    var since = await _cursors.getPullCursor(_serverPeerId);

    while (true) {
      final page = await _http.fetchChanges(
          serverUrl: serverUrl, token: token, since: since, limit: _pageSize);

      var appliedCount = 0;
      for (final change in page.changes) {
        final resolved =
            await _resolveIncomingPhoto(serverUrl, token, change);
        if (resolved == null) break; // photo download failed; retry next sync
        await _storage.applyRemoteChange(resolved);
        appliedCount++;
      }
      total += appliedCount;

      if (appliedCount > 0) {
        final newCursor = page.changes[appliedCount - 1].rev;
        await _cursors.setPullCursor(_serverPeerId, newCursor);
        since = newCursor;
        // Best-effort bookkeeping only -- failures here don't affect
        // correctness (see SyncHttpClient.ack).
        await _http
            .ack(
                serverUrl: serverUrl,
                token: token,
                deviceId: deviceId,
                cursor: newCursor)
            .catchError((_) {});
      }

      if (appliedCount < page.changes.length) break;
      if (!page.hasMore) break;
    }

    return total;
  }

  // -- push: the client-server equivalent of a peer initiating a push,
  //    internally applied server-side via the same receiveChanges logic ----

  Future<int> _push({
    required String serverUrl,
    required String token,
    required String deviceId,
  }) async {
    var total = 0;

    while (true) {
      final since = await _cursors.getPushCursor(_serverPeerId);
      final batch = await _storage.localChangesSince(since,
          limit: _pageSize, deviceId: deviceId);
      if (batch.isEmpty) break;

      final prepared = <EntityChange>[];
      for (final change in batch) {
        final ready = await _prepareOutgoingPhoto(serverUrl, token, change);
        if (ready == null) break; // upload failed; retry next sync
        prepared.add(ready);
      }
      if (prepared.isEmpty) break;

      await _http.receiveChanges(
        serverUrl: serverUrl,
        token: token,
        deviceId: deviceId,
        changes: prepared,
      );

      final maxRev = prepared.map((c) => c.rev).reduce((a, b) => a > b ? a : b);
      await _cursors.setPushCursor(_serverPeerId, maxRev);
      total += prepared.length;

      if (prepared.length < batch.length) break; // a photo failed partway
      if (batch.length < _pageSize) break;
    }

    return total;
  }

  // -- photo side channel ------------------------------------------------

  Future<EntityChange?> _resolveIncomingPhoto(
      String serverUrl, String token, EntityChange change) async {
    if (change.entityType != 'entry') return change;
    final photoKey = change.payload['photoKey'] as String?;
    if (photoKey == null) return change;

    final localPath = await _photos.download(
        serverUrl: serverUrl, token: token, photoKey: photoKey);
    if (localPath == null) return null;

    final payload = Map<String, dynamic>.from(change.payload)
      ..remove('photoKey')
      ..['photoPath'] = localPath;
    return EntityChange(
      entityType: change.entityType,
      entityId: change.entityId,
      payload: payload,
      updatedAt: change.updatedAt,
      deletedAt: change.deletedAt,
      deviceId: change.deviceId,
      rev: change.rev,
    );
  }

  Future<EntityChange?> _prepareOutgoingPhoto(
      String serverUrl, String token, EntityChange change) async {
    if (change.entityType != 'entry' || change.deletedAt != null) return change;
    final photoPath = change.payload['photoPath'] as String?;
    if (photoPath == null) return change;

    final photoKey = await _photos.upload(
      serverUrl: serverUrl,
      token: token,
      entityId: change.entityId,
      localPath: photoPath,
    );
    if (photoKey == null) return null;

    final payload = Map<String, dynamic>.from(change.payload)
      ..remove('photoPath')
      ..['photoKey'] = photoKey;
    return EntityChange(
      entityType: change.entityType,
      entityId: change.entityId,
      payload: payload,
      updatedAt: change.updatedAt,
      deletedAt: change.deletedAt,
      deviceId: change.deviceId,
      rev: change.rev,
    );
  }
}
