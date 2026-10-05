import 'package:drift/drift.dart';

import 'app_database.dart';

part 'sync_cursors_dao.g.dart';

const syncDirectionPull = 'pull';
const syncDirectionPush = 'push';

/// Direction prefix of a backfill pull's own cursor, keyed by the entry
/// types it fetches so a backfill for a different set starts over.
const syncDirectionBackfillPrefix = 'backfill:';

/// Direction prefix of the cursor of a pull fetching whole entity types
/// that this device used to ignore, keyed by those types.
const syncDirectionEntityBackfillPrefix = 'backfill-entities:';

/// Peer id for the (today, only) remote peer a workspace can sync with.
/// Cursor rows are already scoped per-workspace (each remote workspace is
/// its own SQLite file), so a single constant peer id is enough -- see
/// SyncCursorsTable's doc comment.
const syncServerPeerId = 'server';

@DriftAccessor(
    tables: [SyncCursorsTable, SyncEntryTypesTable, SyncEntityTypesTable])
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

  /// Entry types already declared to [peerId], or null if none were ever
  /// recorded.
  Future<Set<String>?> getDeclaredEntryTypes(String peerId) async {
    final rows = await (select(syncEntryTypesTable)
          ..where((t) => t.peerId.equals(peerId)))
        .get();
    return rows.isEmpty ? null : {for (final r in rows) r.entryType};
  }

  Future<void> addDeclaredEntryTypes(String peerId, Iterable<String> types) =>
      batch((b) => b.insertAllOnConflictUpdate(syncEntryTypesTable, [
            for (final type in types)
              SyncEntryTypesTableCompanion.insert(
                  peerId: peerId, entryType: type),
          ]));

  /// Declares [types] and drops every backfill cursor of [peerId] at once,
  /// so an interrupted pass can't leave one without the other.
  Future<void> completeBackfill(String peerId, Iterable<String> types) =>
      transaction(() async {
        await addDeclaredEntryTypes(peerId, types);
        await (delete(syncCursorsTable)
              ..where((t) =>
                  t.peerId.equals(peerId) &
                  t.direction.like('$syncDirectionBackfillPrefix%')))
            .go();
      });

  /// Entity types already declared to [peerId], or null if none were ever
  /// recorded.
  Future<Set<String>?> getDeclaredEntityTypes(String peerId) async {
    final rows = await (select(syncEntityTypesTable)
          ..where((t) => t.peerId.equals(peerId)))
        .get();
    return rows.isEmpty ? null : {for (final r in rows) r.entityType};
  }

  Future<void> addDeclaredEntityTypes(
          String peerId, Iterable<String> types) =>
      batch((b) => b.insertAllOnConflictUpdate(syncEntityTypesTable, [
            for (final type in types)
              SyncEntityTypesTableCompanion.insert(
                  peerId: peerId, entityType: type),
          ]));

  /// Declares the entity [types] and drops their backfill cursors.
  Future<void> completeEntityBackfill(String peerId, Iterable<String> types) =>
      transaction(() async {
        await addDeclaredEntityTypes(peerId, types);
        await (delete(syncCursorsTable)
              ..where((t) =>
                  t.peerId.equals(peerId) &
                  t.direction.like('$syncDirectionEntityBackfillPrefix%')))
            .go();
      });
}
