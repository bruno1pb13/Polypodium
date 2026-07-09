import 'package:drift/drift.dart';

import 'app_database.dart';

part 'sync_cursors_dao.g.dart';

const syncDirectionPull = 'pull';
const syncDirectionPush = 'push';

/// Peer id for the (today, only) remote peer a workspace can sync with.
/// Cursor rows are already scoped per-workspace (each remote workspace is
/// its own SQLite file), so a single constant peer id is enough -- see
/// SyncCursorsTable's doc comment.
const syncServerPeerId = 'server';

@DriftAccessor(tables: [SyncCursorsTable])
class SyncCursorsDao extends DatabaseAccessor<AppDatabase>
    with _$SyncCursorsDaoMixin {
  SyncCursorsDao(super.db);

  Future<int> getCursor(String peerId, String direction) async {
    final row = await (select(syncCursorsTable)
          ..where((t) => t.peerId.equals(peerId) & t.direction.equals(direction)))
        .getSingleOrNull();
    return row?.cursor ?? 0;
  }

  Future<void> setCursor(String peerId, String direction, int cursor) =>
      into(syncCursorsTable).insertOnConflictUpdate(
        SyncCursorsTableCompanion.insert(
          peerId: peerId,
          direction: direction,
          cursor: Value(cursor),
        ),
      );
}
