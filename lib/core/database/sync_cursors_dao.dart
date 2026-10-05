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

  /// Only ever moves the cursor forward: the UI and the WorkManager isolate
  /// may sync the same database concurrently, and a slower pass must not
  /// rewind what a faster one already recorded.
  Future<void> setCursor(String peerId, String direction, int cursor) =>
      customUpdate(
        'INSERT INTO sync_cursors (peer_id, direction, cursor) '
        'VALUES (?, ?, ?) ON CONFLICT (peer_id, direction) '
        'DO UPDATE SET cursor = MAX(cursor, excluded.cursor)',
        variables: [
          Variable.withString(peerId),
          Variable.withString(direction),
          Variable.withInt(cursor),
        ],
        updates: {syncCursorsTable},
        updateKind: UpdateKind.update,
      );
}
