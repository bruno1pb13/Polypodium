import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/enums.dart';
import 'plants_table.dart';

part 'plants_dao.g.dart';

@DriftAccessor(tables: [PlantsTable])
class PlantsDao extends DatabaseAccessor<AppDatabase> with _$PlantsDaoMixin {
  PlantsDao(super.db);

  Future<List<PlantsTableData>> getAll() =>
      (select(plantsTable)..orderBy([(t) => OrderingTerm.asc(t.nickname)]))
          .get();

  Stream<List<PlantsTableData>> watchAll() =>
      (select(plantsTable)..orderBy([(t) => OrderingTerm.asc(t.nickname)]))
          .watch();

  Future<PlantsTableData?> getById(String id) =>
      (select(plantsTable)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> upsert(PlantsTableCompanion companion) =>
      into(plantsTable).insertOnConflictUpdate(companion);

  Future<void> updateLastIrrigated(String id, DateTime when) =>
      (update(plantsTable)..where((t) => t.id.equals(id)))
          .write(PlantsTableCompanion(lastIrrigatedAt: Value(when)));

  Future<void> updateSyncStatus(String id, SyncStatus status) =>
      (update(plantsTable)..where((t) => t.id.equals(id)))
          .write(PlantsTableCompanion(syncStatus: Value(status)));

  Future<int> deleteById(String id) =>
      (delete(plantsTable)..where((t) => t.id.equals(id))).go();
}
