import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart';

part 'soils_dao.g.dart';

@DriftAccessor(tables: [SoilsTable])
class SoilsDao extends DatabaseAccessor<AppDatabase> with _$SoilsDaoMixin {
  SoilsDao(super.db);

  Future<List<SoilsTableData>> getAllSoils() =>
      (select(soilsTable)..where((t) => t.deletedAt.isNull())).get();

  Stream<List<SoilsTableData>> watchAllSoils() =>
      (select(soilsTable)..where((t) => t.deletedAt.isNull())).watch();

  Future<int> insertSoil(SoilsTableCompanion soil) =>
      into(soilsTable).insert(soil, mode: InsertMode.insertOrReplace);

  Future<SoilsTableData?> getSoilById(String id) =>
      (select(soilsTable)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> softDelete(String id,
          {required DateTime deletedAt, required int rev}) =>
      (update(soilsTable)..where((t) => t.id.equals(id))).write(
        SoilsTableCompanion(
          deletedAt: Value(deletedAt),
          updatedAt: Value(deletedAt),
          localRev: Value(rev),
        ),
      );

  Future<List<SoilsTableData>> changesSince(int since,
          {required int limit}) =>
      (select(soilsTable)
            ..where((t) => t.localRev.isBiggerThanValue(since))
            ..orderBy([(t) => OrderingTerm.asc(t.localRev)])
            ..limit(limit))
          .get();
}
