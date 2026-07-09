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
}
