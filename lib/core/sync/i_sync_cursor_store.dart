/// Per-peer pull/push bookmarks. Abstracted away from SyncCursorsDao so the
/// orchestrator doesn't depend on Drift directly.
abstract interface class ISyncCursorStore {
  Future<int> getPullCursor(String peerId);
  Future<void> setPullCursor(String peerId, int cursor);

  Future<int> getPushCursor(String peerId);
  Future<void> setPushCursor(String peerId, int cursor);
}
