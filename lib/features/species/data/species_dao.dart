import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/enums.dart';
import 'species_table.dart';

part 'species_dao.g.dart';

@DriftAccessor(tables: [SpeciesTable])
class SpeciesDao extends DatabaseAccessor<AppDatabase> with _$SpeciesDaoMixin {
  SpeciesDao(super.db);

  Future<List<SpeciesTableData>> getAll() =>
      (select(speciesTable)..orderBy([(t) => OrderingTerm.asc(t.popularName)]))
          .get();

  Stream<List<SpeciesTableData>> watchAll() =>
      (select(speciesTable)..orderBy([(t) => OrderingTerm.asc(t.popularName)]))
          .watch();

  Future<SpeciesTableData?> getById(String id) =>
      (select(speciesTable)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> upsert(SpeciesTableCompanion companion) =>
      into(speciesTable).insertOnConflictUpdate(companion);

  Future<void> updateSyncStatus(String id, SyncStatus status) =>
      (update(speciesTable)..where((t) => t.id.equals(id)))
          .write(SpeciesTableCompanion(syncStatus: Value(status)));

  Future<int> deleteById(String id) =>
      (delete(speciesTable)..where((t) => t.id.equals(id))).go();
}
