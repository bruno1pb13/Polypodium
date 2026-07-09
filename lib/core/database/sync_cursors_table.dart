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
