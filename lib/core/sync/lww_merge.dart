/// Whether an incoming remote change should overwrite the local row.
///
/// Same last-write-wins-by-edit-time rule as the server's `ON CONFLICT`
/// clause in `Polypodium_server/lib/features/sync/sync_repository.dart` --
/// a strictly newer `updatedAt` always wins, replacing the old event-log
/// behavior of resolving conflicts by arrival order instead of real edit
/// time.
///
/// Unlike the server, the client does not persist a per-row `deviceId`
/// locally (only the wire format carries one), so on an exact `updatedAt`
/// tie the remote change wins by default rather than tiebreaking on
/// deviceId. Exact-timestamp collisions between two independent devices'
/// human-paced edits are negligible for this app; if that ever needs to
/// change, a `deviceId` column would have to be added to every entity
/// table to restore full symmetry with the server's comparator.
bool shouldApplyRemote({
  required DateTime? localUpdatedAt,
  required DateTime remoteUpdatedAt,
}) {
  if (localUpdatedAt == null) return true;
  return !remoteUpdatedAt.isBefore(localUpdatedAt);
}
