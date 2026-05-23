import 'package:drift/drift.dart';

// TODO(sync): This table feeds the future server synchronization layer.
// Each write operation enqueues a record here; the sync service drains it.
class SyncQueueTable extends Table {
  @override
  String get tableName => 'sync_queue';

  IntColumn get id => integer().autoIncrement()();

  /// 'species' | 'plant' | 'entry'
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();

  /// 'create' | 'update' | 'delete'
  TextColumn get operation => text()();

  /// JSON-encoded snapshot of the entity at the time of the write
  TextColumn get payload => text()();

  BoolColumn get processed => boolean().withDefault(const Constant(false))();

  DateTimeColumn get createdAt => dateTime()();
}
