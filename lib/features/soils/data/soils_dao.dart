import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart';

part 'soils_dao.g.dart';

@DriftAccessor(tables: [SoilsTable])
class SoilsDao extends DatabaseAccessor<AppDatabase> with _$SoilsDaoMixin {
  SoilsDao(super.db);

  Future<List<SoilsTableData>> getAllSoils() => select(soilsTable).get();
  
  Stream<List<SoilsTableData>> watchAllSoils() => select(soilsTable).watch();

  Future<int> insertSoil(SoilsTableCompanion soil) =>
      into(soilsTable).insert(soil, mode: InsertMode.insertOrReplace);

  Future<bool> updateSoil(SoilsTableCompanion soil) =>
      update(soilsTable).replace(soil);

  Future<int> deleteSoil(String id) =>
      (delete(soilsTable)..where((t) => t.id.equals(id))).go();
      
  Future<SoilsTableData?> getSoilById(String id) =>
      (select(soilsTable)..where((t) => t.id.equals(id))).getSingleOrNull();
}
