import 'package:drift/drift.dart';

/// Per-peer, per-direction sync bookmark. `direction` is 'pull' (highest
/// remote rev we've successfully applied from that peer) or 'push' (highest
/// local rev we've successfully delivered to that peer). Keyed by peer, not
/// by entity type, since revisions come from the single shared counter in
/// SyncMetaTable/mat_rev_seq -- one cursor per peer-direction is enough.
class SyncCursorsTable extends Table {
  @override
  String get tableName => 'sync_cursors';

  TextColumn get peerId => text()();

  /// 'pull' | 'push'
  TextColumn get direction => text()();
  IntColumn get cursor => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {peerId, direction};
}

/// Entry types this device has already declared to a peer on pull (see
/// SyncOrchestrator's backfill). Lives next to the pull cursor because it
/// qualifies it: rows of an undeclared type were withheld from everything
/// behind that cursor.
class SyncEntryTypesTable extends Table {
  @override
  String get tableName => 'sync_entry_types';

  TextColumn get peerId => text()();
  TextColumn get entryType => text()();

  @override
  Set<Column> get primaryKey => {peerId, entryType};
}

/// Entity types this device has already declared to a peer, i.e. applied on
/// pull. Rows of a type an older release ignored were skipped behind the
/// pull cursor all the same, so a release that starts applying a type
/// fetches it once from the start (see SyncOrchestrator's backfill).
class SyncEntityTypesTable extends Table {
  @override
  String get tableName => 'sync_entity_types';

  TextColumn get peerId => text()();
  TextColumn get entityType => text()();

  @override
  Set<Column> get primaryKey => {peerId, entityType};
}
