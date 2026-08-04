import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart';

part 'defensivos_dao.g.dart';

@DriftAccessor(tables: [DefensivosTable])
class DefensivosDao extends DatabaseAccessor<AppDatabase>
    with _$DefensivosDaoMixin {
  DefensivosDao(super.db);

  Future<List<DefensivosTableData>> getAllDefensivos() =>
      (select(defensivosTable)..where((t) => t.deletedAt.isNull())).get();

  Stream<List<DefensivosTableData>> watchAllDefensivos() =>
      (select(defensivosTable)..where((t) => t.deletedAt.isNull())).watch();

  Future<int> insertDefensivo(DefensivosTableCompanion defensivo) =>
      into(defensivosTable).insert(defensivo, mode: InsertMode.insertOrReplace);

  Future<DefensivosTableData?> getDefensivoById(String id) =>
      (select(defensivosTable)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Future<void> softDelete(String id,
          {required DateTime deletedAt, required int rev}) =>
      (update(defensivosTable)..where((t) => t.id.equals(id))).write(
        DefensivosTableCompanion(
          deletedAt: Value(deletedAt),
          updatedAt: Value(deletedAt),
          localRev: Value(rev),
        ),
      );

  Future<List<DefensivosTableData>> changesSince(int since,
          {required int limit}) =>
      (select(defensivosTable)
            ..where((t) => t.localRev.isBiggerThanValue(since))
            ..orderBy([(t) => OrderingTerm.asc(t.localRev)])
            ..limit(limit))
          .get();
}
