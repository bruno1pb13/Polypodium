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

/// Entity types every release before `entry_photo` applied on pull.
const legacyEntityTypes = {
  'species',
  'soil',
  'location',
  'plant',
  'entry',
  'defensivo',
  'reminder',
};

/// Entity types every server with per-entity tables stored (its `_matTable`
/// since Polypodium_server 386c0f1), so no server ever dropped them on push.
const originalServerEntityTypes = {
  'species',
  'plant',
  'entry',
  'location',
  'soil',
  'bed',
};

/// Entity types left out of the essentials a fresh device pulls first: the
/// history, by far the bulk of a garden, and the only part with photos.
const historyEntityTypes = {'entry', 'entry_photo'};

/// Pulls above this many changes are worth telling the user about.
const largeSyncThreshold = 300;

/// Entities whose payload carries a photo file through the photo side
/// channel (`photoPath` locally, `photoKey` on the wire).
const _photoEntityTypes = {'entry', 'entry_photo'};

class SyncResult {
  final int pulled;
  final int pushed;
  const SyncResult({required this.pulled, required this.pushed});
}

enum SyncStage {
  /// A fresh device pulling everything but the history, before the user
  /// gets the app: without it the plant list would fill in for minutes.
  essentials,

  /// The regular pull. Data may still be missing while it runs.
  rest,
}

/// Where a running pull stands, reported after each page.
class SyncProgress {
  final SyncStage stage;

  /// Changes applied so far in this stage.
  final int done;

  /// Changes this stage holds in all; null when the server can't tell.
  final int? total;

  /// Whether the pull is big enough to tell the user about.
  final bool large;

  const SyncProgress({
    required this.stage,
    required this.done,
    this.total,
    this.large = false,
  });
}

/// Orchestrates a full sync cycle against one peer (today: always "the
/// server", identified by [_serverPeerId] -- a future LAN peer would reuse
/// the same orchestrator against a different peer id/URL). Depends only on
/// the storage/cursor/transport abstractions, never on Drift or `http`
/// directly, so each side can be swapped/tested independently.
/// Reports a pull's applied changes so far, out of its size (null when
/// unknown), and whether more pages follow.
typedef _PageProgress = void Function(int done, int? total, bool hasMore);

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

  /// [onProgress] follows the pull, the part that grows with the garden;
  /// it gets null once the pull is done.
  Future<SyncResult> sync({
    required String serverUrl,
    required String token,
    required String deviceId,
    void Function(SyncProgress? progress)? onProgress,
  }) async {
    final fresh = await _cursors.getPullCursor(_serverPeerId) == 0;
    // Before the pull, which moves the cursor the first record depends on.
    final newEntryTypes = await _undeclaredEntryTypes();
    final newEntities = await _undeclaredEntityTypes();
    // Before the push, which moves the cursor a fresh device is told by.
    final pushedBefore = await _cursors.getPushCursor(_serverPeerId) > 0;
    final essentialsFirst = fresh &&
        await _pullsEssentialsFirst(serverUrl: serverUrl, token: token);
    if (essentialsFirst) {
      onProgress?.call(const SyncProgress(
          stage: SyncStage.essentials, done: 0, large: true));
      await _pullEssentials(
          serverUrl: serverUrl, token: token, onProgress: onProgress);
    }
    final pull = await _pull(
        serverUrl: serverUrl,
        token: token,
        deviceId: deviceId,
        onProgress: onProgress == null
            ? null
            : (done, total, hasMore) => onProgress(SyncProgress(
                  stage: SyncStage.rest,
                  done: done,
                  total: total,
                  large: essentialsFirst ||
                      (total != null
                          ? total > largeSyncThreshold
                          : hasMore && done >= largeSyncThreshold),
                )));
    onProgress?.call(null);
    // The essentials came again with the full pull, so they're counted once.
    var pulled = pull.applied;
    final supported = pull.supported;
    final repush = supported == null
        ? const <String>{}
        : await _unconfirmedEntityTypes(supported, pushedBefore: pushedBefore);
    var pushed = await _push(
        serverUrl: serverUrl, token: token, deviceId: deviceId);
    for (final entityType in repush) {
      pushed += await _repush(
          serverUrl: serverUrl,
          token: token,
          deviceId: deviceId,
          entityType: entityType);
    }
    if (newEntryTypes.isNotEmpty) {
      pulled += await _backfill(
          serverUrl: serverUrl, token: token, entryTypes: newEntryTypes);
    }
    if (newEntities.isNotEmpty) {
      pulled += await _backfillEntities(
          serverUrl: serverUrl, token: token, entityTypes: newEntities);
    }
    return SyncResult(pulled: pulled, pushed: pushed);
  }

  // -- pull: real GET, applies the server's changes locally ------------------

  /// Returns the server's [supported] entity types along with how many
  /// changes were applied.
  Future<({int applied, Set<String>? supported})> _pull({
    required String serverUrl,
    required String token,
    required String deviceId,
    _PageProgress? onProgress,
  }) async {
    final result = await _pullPages(
      serverUrl: serverUrl,
      token: token,
      since: await _cursors.getPullCursor(_serverPeerId),
      onProgress: onProgress,
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
    return (applied: result.applied, supported: result.supported);
  }

  // -- essentials first: a fresh device facing a big garden pulls every
  //    entity but the history before the regular pull, so the user gets
  //    the plants in seconds and the history fills in behind. Nothing is
  //    persisted: the regular pull starts from rev 0 all the same and
  //    brings the essentials again, which LWW applies as no-ops, and an
  //    interrupted pass just starts over on a device still fresh. ----------

  /// Whether the whole garden is too big to wait for, or of unknown size.
  Future<bool> _pullsEssentialsFirst({
    required String serverUrl,
    required String token,
  }) async {
    final probe = await _http.fetchChanges(
        serverUrl: serverUrl, token: token, since: 0, limit: 1, count: true);
    if (probe.changes.isEmpty) return false;
    final total = probe.remaining;
    return total == null || total > largeSyncThreshold;
  }

  Future<void> _pullEssentials({
    required String serverUrl,
    required String token,
    void Function(SyncProgress? progress)? onProgress,
  }) async {
    await _pullPages(
      serverUrl: serverUrl,
      token: token,
      since: 0,
      entities: _storage.entityTypes.difference(historyEntityTypes),
      onApplied: (_) async {},
      onProgress: onProgress == null
          ? null
          : (done, total, _) => onProgress(SyncProgress(
              stage: SyncStage.essentials,
              done: done,
              total: total,
              large: true)),
    );
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
    final (:applied, :completed, echoed: _, supported: _) = await _pullPages(
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

  // -- entity backfill: same idea for whole entity types an older release
  //    ignored on pull (no-op in its applyRemoteChange) while its cursor
  //    moved past them. ------------------------------------------------------

  /// Entity types this build applies that weren't declared to the server
  /// yet. With nothing recorded, a device that already pulled is assumed to
  /// have applied the legacy set, and a fresh one has nothing to catch up on.
  Future<Set<String>> _undeclaredEntityTypes() async {
    final current = _storage.entityTypes;
    var declared = await _cursors.getDeclaredEntityTypes(_serverPeerId);
    if (declared == null) {
      declared = await _cursors.getPullCursor(_serverPeerId) > 0
          ? legacyEntityTypes.intersection(current)
          : current;
      await _cursors.addDeclaredEntityTypes(_serverPeerId, declared);
    }
    return current.difference(declared);
  }

  Future<int> _backfillEntities({
    required String serverUrl,
    required String token,
    required Set<String> entityTypes,
  }) async {
    final (:applied, :completed, :echoed, supported: _) = await _pullPages(
      serverUrl: serverUrl,
      token: token,
      since:
          await _cursors.getEntityBackfillCursor(_serverPeerId, entityTypes),
      entities: entityTypes,
      onApplied: (cursor) => _cursors.setEntityBackfillCursor(
          _serverPeerId, entityTypes, cursor),
    );
    // A server that doesn't echo the restriction predates it, and with it
    // these entity types: there's nothing to recover. One that echoes only
    // part of them doesn't store the rest yet, and may once updated.
    if (completed && (echoed == null || echoed.containsAll(entityTypes))) {
      await _cursors.completeEntityBackfill(_serverPeerId, entityTypes);
    }
    return applied;
  }

  /// Pulls pages from [since], applying each change and reporting the rev
  /// of the last one applied per page to [onApplied]. Not [completed] when
  /// cut short by a failed photo download. [echoed] is the entity
  /// restriction as the server echoed it (null without one), [supported]
  /// the entity types it reported storing. With [onProgress], the first
  /// page asks the server for the pull's size.
  Future<
      ({
        int applied,
        bool completed,
        Set<String>? echoed,
        Set<String>? supported,
      })> _pullPages({
    required String serverUrl,
    required String token,
    required int since,
    required Future<void> Function(int cursor) onApplied,
    Set<String>? entryTypes,
    Set<String>? entities,
    _PageProgress? onProgress,
  }) async {
    var total = 0;
    var first = true;
    int? size;

    while (true) {
      final page = await _http.fetchChanges(
          serverUrl: serverUrl,
          token: token,
          since: since,
          limit: _pageSize,
          entryTypes: entryTypes,
          entities: entities,
          count: onProgress != null && first);
      first = false;
      size ??= page.remaining;
      final supported = page.supportedEntities;
      if (entities != null && page.entities == null) {
        return (
          applied: total,
          completed: true,
          echoed: null,
          supported: supported,
        );
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
      // Rows written meanwhile can outgrow the count taken up front.
      final sizeNow = size == null ? null : (total > size ? total : size);
      onProgress?.call(total, sizeNow, page.hasMore);

      if (appliedCount < page.changes.length || !page.hasMore) {
        return (
          applied: total,
          completed: appliedCount == page.changes.length,
          echoed: page.entities,
          supported: supported,
        );
      }
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

      final (:prepared, :ignored) = await _deliver(
          serverUrl: serverUrl, token: token, deviceId: deviceId, batch: batch);
      if (prepared.isEmpty) break;
      // Moving past them all the same keeps the other types flowing; they're
      // re-pushed once the server stores them.
      if (ignored != null && ignored.isNotEmpty) {
        await _cursors.unconfirmEntityTypes(_serverPeerId, ignored);
      }

      await _cursors.setPushCursor(_serverPeerId, _maxRev(prepared));
      total += prepared.length;

      if (prepared.length < batch.length) break; // a photo failed partway
      if (batch.length < _pageSize) break;
    }

    return total;
  }

  /// Prepares the photos of [batch] and sends it, cut short before the
  /// first change whose photo failed to upload (retried next sync).
  /// [ignored] are the entity types the server reported dropping.
  Future<({List<SyncChange> prepared, Set<String>? ignored})> _deliver({
    required String serverUrl,
    required String token,
    required String deviceId,
    required List<SyncChange> batch,
    bool skipExistingPhotos = false,
  }) async {
    final prepared = <SyncChange>[];
    for (final change in batch) {
      final ready = await _prepareOutgoingPhoto(serverUrl, token, change,
          skipExisting: skipExistingPhotos);
      if (ready == null) break;
      prepared.add(ready);
    }
    if (prepared.isEmpty) return (prepared: prepared, ignored: null);

    final result = await _http.receiveChanges(
      serverUrl: serverUrl,
      token: token,
      deviceId: deviceId,
      changes: prepared,
    );
    return (prepared: prepared, ignored: result.ignoredEntityTypes);
  }

  static int _maxRev(List<SyncChange> changes) =>
      changes.map((c) => c.rev).reduce((a, b) => a > b ? a : b);

  // -- re-push: a server predating `ignoredEntityTypes` dropped the rows of
  //    types it didn't store yet in silence, while the push cursor moved
  //    past them. Once it reports storing such a type, every local row of
  //    it is sent once more, on a cursor of its own; LWW on the server
  //    makes resending what it already has a no-op. ------------------------

  /// Entity types this build pushes that the server reports storing but
  /// never confirmed, after confirming those that need no re-push: the
  /// types every server stored, and, on a device that never pushed, all of
  /// them (the regular push sends their rows anyway). Types the server
  /// stopped reporting are unconfirmed.
  Future<Set<String>> _unconfirmedEntityTypes(Set<String> supported,
      {required bool pushedBefore}) async {
    final confirmed = await _cursors.getConfirmedEntityTypes(_serverPeerId);
    final dropped = confirmed.difference(supported);
    if (dropped.isNotEmpty) {
      await _cursors.unconfirmEntityTypes(_serverPeerId, dropped);
    }
    final pending =
        _storage.entityTypes.intersection(supported).difference(confirmed);
    final safe = pushedBefore
        ? pending.intersection(originalServerEntityTypes)
        : pending;
    if (safe.isNotEmpty) {
      await _cursors.confirmEntityTypes(_serverPeerId, safe);
    }
    return pending.difference(safe);
  }

  /// Re-pushes every local row of [entityType] (only rows written here:
  /// pulled ones came from the server), resuming where an interrupted pass
  /// stopped, and confirms the type once the server took them all.
  Future<int> _repush({
    required String serverUrl,
    required String token,
    required String deviceId,
    required String entityType,
  }) async {
    var total = 0;

    while (true) {
      final since = await _cursors.getRepushCursor(_serverPeerId, entityType);
      final batch = await _storage.localChangesOfTypeSince(entityType, since,
          limit: _pageSize, deviceId: deviceId);
      if (batch.isEmpty) break;

      // Their photos were uploaded the first time, whatever became of the
      // rows, so only the missing ones are sent.
      final (:prepared, :ignored) = await _deliver(
          serverUrl: serverUrl,
          token: token,
          deviceId: deviceId,
          batch: batch,
          skipExistingPhotos: true);
      if (prepared.isEmpty) return total;
      if (ignored != null && ignored.contains(entityType)) {
        // Downgraded since the pull: start over once it's back.
        await _cursors.unconfirmEntityTypes(_serverPeerId, {entityType});
        return total;
      }

      await _cursors.setRepushCursor(
          _serverPeerId, entityType, _maxRev(prepared));
      total += prepared.length;

      if (prepared.length < batch.length) return total;
      if (batch.length < _pageSize) break;
    }

    await _cursors.confirmEntityTypes(_serverPeerId, {entityType});
    return total;
  }

  // -- photo side channel ------------------------------------------------

  Future<SyncChange?> _resolveIncomingPhoto(
      String serverUrl, String token, SyncChange change) async {
    if (!_photoEntityTypes.contains(change.entityType)) return change;
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
      String serverUrl, String token, SyncChange change,
      {bool skipExisting = false}) async {
    if (!_photoEntityTypes.contains(change.entityType) ||
        change.deletedAt != null) {
      return change;
    }
    final photoPath = change.payload['photoPath'] as String?;
    if (photoPath == null) return change;

    final photoKey = await _photos.upload(
      serverUrl: serverUrl,
      token: token,
      entityId: change.entityId,
      localPath: photoPath,
      skipExisting: skipExisting,
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
