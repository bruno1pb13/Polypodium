import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/enums.dart';
import 'entries_table.dart';

part 'entries_dao.g.dart';

@DriftAccessor(tables: [EntriesTable])
class EntriesDao extends DatabaseAccessor<AppDatabase> with _$EntriesDaoMixin {
  EntriesDao(super.db);

  Future<List<EntriesTableData>> getByPlant(String plantId) =>
      (select(entriesTable)
            ..where((t) => t.plantId.equals(plantId))
            ..orderBy([(t) => OrderingTerm.desc(t.date)]))
          .get();

  Stream<List<EntriesTableData>> watchByPlant(String plantId) =>
      (select(entriesTable)
            ..where((t) => t.plantId.equals(plantId))
            ..orderBy([(t) => OrderingTerm.desc(t.date)]))
          .watch();

  Future<void> insert(EntriesTableCompanion companion) =>
      into(entriesTable).insert(companion);

  Future<void> updateSyncStatus(String id, SyncStatus status) =>
      (update(entriesTable)..where((t) => t.id.equals(id)))
          .write(EntriesTableCompanion(syncStatus: Value(status)));

  Future<int> deleteById(String id) =>
      (delete(entriesTable)..where((t) => t.id.equals(id))).go();

  Future<List<String>> getPhotoPathsForPlant(String plantId) async {
    final rows = await (select(entriesTable)
          ..where((t) => t.plantId.equals(plantId) & t.photoPath.isNotNull()))
        .get();
    return rows.map((r) => r.photoPath!).toList();
  }

  /// Returns the IDs (and photo paths) of entries that exceed the retention
  /// limit, ordered oldest-first so the caller can delete them.
  Future<List<EntriesTableData>> getOverRetentionLimit(
    String plantId, {
    int keepCount = 30,
  }) async {
    final all = await getByPlant(plantId); // newest first
    if (all.length <= keepCount) return [];
    return all.sublist(keepCount); // oldest entries beyond the limit
  }
}
