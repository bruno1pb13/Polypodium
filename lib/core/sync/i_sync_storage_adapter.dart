import 'models/entity_change.dart';

/// Storage-side half of the sync contract -- reading/writing local entity
/// tables. Kept separate from transport (SyncHttpClient) and orchestration
/// (SyncOrchestrator) so each can vary independently (SOLID: single
/// responsibility + dependency inversion -- the orchestrator depends on
/// this abstraction, not on Drift directly).
abstract interface class ISyncStorageAdapter {
  /// Local changes across every entity type (including tombstones -- sync
  /// must propagate deletes) with rev > [since], merge-sorted by rev, with
  /// at most [limit] returned. [deviceId] stamps who authored these
  /// changes on the wire (the adapter has no notion of device identity
  /// itself).
  Future<List<EntityChange>> localChangesSince(
    int since, {
    required int limit,
    required String deviceId,
  });

  /// Applies one remote change via last-write-wins; a no-op if the local
  /// row (when one exists) is already newer. Applying resets the row's
  /// local rev to 0 -- data that just arrived from a peer is inherently
  /// already in sync with that peer, so it must not be redelivered to it
  /// on the next push.
  Future<void> applyRemoteChange(EntityChange change);
}
