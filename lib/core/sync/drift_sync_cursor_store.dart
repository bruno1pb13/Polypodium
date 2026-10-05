import '../database/app_database.dart';
import '../database/sync_cursors_dao.dart';
import 'i_sync_cursor_store.dart';

class DriftSyncCursorStore implements ISyncCursorStore {
  DriftSyncCursorStore(AppDatabase db) : _dao = db.syncCursorsDao;

  final SyncCursorsDao _dao;

  @override
  Future<int> getPullCursor(String peerId) =>
      _dao.getCursor(peerId, syncDirectionPull);

  @override
  Future<void> setPullCursor(String peerId, int cursor) =>
      _dao.setCursor(peerId, syncDirectionPull, cursor);

  @override
  Future<int> getPushCursor(String peerId) =>
      _dao.getCursor(peerId, syncDirectionPush);

  @override
  Future<void> setPushCursor(String peerId, int cursor) =>
      _dao.setCursor(peerId, syncDirectionPush, cursor);

  @override
  Future<Set<String>?> getDeclaredEntryTypes(String peerId) =>
      _dao.getDeclaredEntryTypes(peerId);

  @override
  Future<void> addDeclaredEntryTypes(String peerId, Set<String> types) =>
      _dao.addDeclaredEntryTypes(peerId, types);

  @override
  Future<int> getBackfillCursor(String peerId, Set<String> entryTypes) =>
      _dao.getCursor(peerId, _backfillDirection(entryTypes));

  @override
  Future<void> setBackfillCursor(
          String peerId, Set<String> entryTypes, int cursor) =>
      _dao.setCursor(peerId, _backfillDirection(entryTypes), cursor);

  @override
  Future<void> completeBackfill(String peerId, Set<String> entryTypes) =>
      _dao.completeBackfill(peerId, entryTypes);

  String _backfillDirection(Set<String> entryTypes) =>
      syncDirectionBackfillPrefix + (entryTypes.toList()..sort()).join(',');
}
