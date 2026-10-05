/// Per-peer pull/push bookmarks. Abstracted away from SyncCursorsDao so the
/// orchestrator doesn't depend on Drift directly.
abstract interface class ISyncCursorStore {
  Future<int> getPullCursor(String peerId);
  Future<void> setPullCursor(String peerId, int cursor);

  Future<int> getPushCursor(String peerId);
  Future<void> setPushCursor(String peerId, int cursor);

  /// Entry types already declared to [peerId] on pull, or null when this
  /// device never recorded any.
  Future<Set<String>?> getDeclaredEntryTypes(String peerId);
  Future<void> addDeclaredEntryTypes(String peerId, Set<String> types);

  /// Cursor of the backfill pull fetching [entryTypes] (0 if none yet).
  Future<int> getBackfillCursor(String peerId, Set<String> entryTypes);
  Future<void> setBackfillCursor(
      String peerId, Set<String> entryTypes, int cursor);

  /// Marks [entryTypes] declared and drops the backfill cursors.
  Future<void> completeBackfill(String peerId, Set<String> entryTypes);

  /// Entity types already applied on pull from [peerId], or null when this
  /// device never recorded any.
  Future<Set<String>?> getDeclaredEntityTypes(String peerId);
  Future<void> addDeclaredEntityTypes(String peerId, Set<String> types);

  /// Cursor of the backfill pull fetching [entityTypes] (0 if none yet).
  Future<int> getEntityBackfillCursor(String peerId, Set<String> entityTypes);
  Future<void> setEntityBackfillCursor(
      String peerId, Set<String> entityTypes, int cursor);

  /// Marks [entityTypes] declared and drops their backfill cursors.
  Future<void> completeEntityBackfill(String peerId, Set<String> entityTypes);
}
