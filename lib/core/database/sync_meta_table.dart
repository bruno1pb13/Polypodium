import 'package:drift/drift.dart';

/// Single-row table (id=0) holding the monotonic revision counter shared by
/// every entity table. One counter across all tables (not one per table)
/// keeps FK-dependency order (species/soils/locations -> plants -> entries)
/// intact as a single stream, mirroring the ordering guarantee a global
/// sequence would give.
class SyncMetaTable extends Table {
  @override
  String get tableName => 'sync_meta';

  IntColumn get id => integer()();
  IntColumn get nextLocalRev => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {id};
}
