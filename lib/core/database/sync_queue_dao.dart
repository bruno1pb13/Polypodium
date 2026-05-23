import 'package:drift/drift.dart';

import 'app_database.dart';

part 'sync_queue_dao.g.dart';

@DriftAccessor(tables: [SyncQueueTable])
class SyncQueueDao extends DatabaseAccessor<AppDatabase>
    with _$SyncQueueDaoMixin {
  SyncQueueDao(super.db);

  // TODO(sync): Called by repositories on every local write
  Future<void> enqueue({
    required String entityType,
    required String entityId,
    required String operation,
    required String payload,
  }) =>
      into(syncQueueTable).insert(
        SyncQueueTableCompanion.insert(
          entityType: entityType,
          entityId: entityId,
          operation: operation,
          payload: payload,
          createdAt: DateTime.now(),
        ),
      );

  // TODO(sync): Called by the sync service to drain pending items
  Future<List<SyncQueueTableData>> getPending() => (select(syncQueueTable)
        ..where((t) => t.processed.equals(false))
        ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
      .get();

  Future<void> markProcessed(int id) =>
      (update(syncQueueTable)..where((t) => t.id.equals(id)))
          .write(const SyncQueueTableCompanion(processed: Value(true)));
}
