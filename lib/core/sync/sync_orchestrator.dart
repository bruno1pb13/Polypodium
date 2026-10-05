import 'package:polypodium_core/polypodium_core.dart';

import '../database/sync_cursors_dao.dart' show syncServerPeerId;
import '../enums.dart';
import 'i_sync_cursor_store.dart';
import 'i_sync_storage_adapter.dart';
import 'photo_sync_client.dart';
import 'sync_http_client.dart';

/// Entry types a device is assumed to have declared before it recorded any:
/// what releases without the `X-Polypodium-Entry-Types` header understood.
/// Mirrors `legacyEntryTypes` in Polypodium_server's sync_repository.dart.
const legacyEntryTypes = {
  'irrigation',
  'fertilizer',
  'pruning',
  'observation',
  'height',
  'chlorosis',
  'pest',
  'pesticide',
  'other',
  'history',
};

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
    // Before the pull, which moves the cursor the first record depends on.
    final newEntryTypes = await _undeclaredEntryTypes();
    var pulled = await _pull(
        serverUrl: serverUrl, token: token, deviceId: deviceId);
    final pushed = await _push(
        serverUrl: serverUrl, token: token, deviceId: deviceId);
    if (newEntryTypes.isNotEmpty) {
      pulled += await _backfill(
          serverUrl: serverUrl, token: token, entryTypes: newEntryTypes);
    }
    return SyncResult(pulled: pulled, pushed: pushed);
  }

  // -- pull: real GET, applies the server's changes locally ------------------

  Future<int> _pull({
    required String serverUrl,
    required String token,
    required String deviceId,
  }) async {
    final result = await _pullPages(
      serverUrl: serverUrl,
      token: token,
      since: await _cursors.getPullCursor(_serverPeerId),
      onApplied: (cursor) async {
        await _cursors.setPullCursor(_serverPeerId, cursor);
        // Best-effort bookkeeping only -- failures here don't affect
        // correctness (see SyncHttpClient.ack).
        await _http
            .ack(
                serverUrl: serverUrl,
                token: token,
                deviceId: deviceId,
                cursor: cursor)
            .catchError((_) {});
      },
    );
    return result.applied;
  }

  // -- backfill: entries of types this build learned since its last
  //    declaration were withheld from everything behind the pull cursor, so
  //    they're fetched once from rev 0 -- entries only, those types only, on
  //    a cursor of their own. Runs after push: it can only bring the server's
  //    current version of each row, which LWW applies or ignores like any
  //    other pulled change. ------------------------------------------------

  /// Entry types this build knows that weren't declared to the server yet.
  /// With nothing recorded, a device that already pulled is assumed to have
  /// declared the legacy set, and a fresh one has nothing to catch up on.
  Future<Set<String>> _undeclaredEntryTypes() async {
    final current = {for (final t in EntryType.values) t.name};
    var declared = await _cursors.getDeclaredEntryTypes(_serverPeerId);
    if (declared == null) {
      declared = await _cursors.getPullCursor(_serverPeerId) > 0
          ? legacyEntryTypes
          : current;
      await _cursors.addDeclaredEntryTypes(_serverPeerId, declared);
    }
    return current.difference(declared);
  }

  Future<int> _backfill({
    required String serverUrl,
    required String token,
    required Set<String> entryTypes,
  }) async {
    const entities = {'entry'};
    final (:applied, :completed) = await _pullPages(
      serverUrl: serverUrl,
      token: token,
      since: await _cursors.getBackfillCursor(_serverPeerId, entryTypes),
      entryTypes: entryTypes,
      entities: entities,
      onApplied: (cursor) =>
          _cursors.setBackfillCursor(_serverPeerId, entryTypes, cursor),
    );
    // Also reached, with nothing applied, when the server ignored the
    // restriction: it predates it, and re-pulling every entity from rev 0
    // on each sync would cost far more than the few rows it might recover.
    if (completed) await _cursors.completeBackfill(_serverPeerId, entryTypes);
    return applied;
  }

  /// Pulls pages from [since], applying each change and reporting the rev
  /// of the last one applied per page to [onApplied]. Not [completed] when
  /// cut short by a failed photo download.
  Future<({int applied, bool completed})> _pullPages({
    required String serverUrl,
    required String token,
    required int since,
    required Future<void> Function(int cursor) onApplied,
    Set<String>? entryTypes,
    Set<String>? entities,
  }) async {
    var total = 0;

    while (true) {
      final page = await _http.fetchChanges(
          serverUrl: serverUrl,
          token: token,
          since: since,
          limit: _pageSize,
          entryTypes: entryTypes,
          entities: entities);
      if (entities != null && page.entities == null) {
        return (applied: total, completed: true);
      }

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
        since = page.changes[appliedCount - 1].rev;
        await onApplied(since);
      }

      if (appliedCount < page.changes.length) {
        return (applied: total, completed: false);
      }
      if (!page.hasMore) return (applied: total, completed: true);
    }
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

      final prepared = <SyncChange>[];
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

  Future<SyncChange?> _resolveIncomingPhoto(
      String serverUrl, String token, SyncChange change) async {
    if (change.entityType != 'entry') return change;
    final photoKey = change.payload['photoKey'] as String?;
    if (photoKey == null) return change;

    final localPath = await _photos.download(
        serverUrl: serverUrl, token: token, photoKey: photoKey);
    if (localPath == null) return null;

    final payload = Map<String, dynamic>.from(change.payload)
      ..remove('photoKey')
      ..['photoPath'] = localPath;
    return SyncChange(
      entityType: change.entityType,
      entityId: change.entityId,
      payload: payload,
      updatedAt: change.updatedAt,
      deletedAt: change.deletedAt,
      deviceId: change.deviceId,
      rev: change.rev,
    );
  }

  Future<SyncChange?> _prepareOutgoingPhoto(
      String serverUrl, String token, SyncChange change) async {
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
    return SyncChange(
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
