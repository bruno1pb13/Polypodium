import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';

part 'plants_dao.g.dart';

@DriftAccessor(tables: [PlantsTable])
class PlantsDao extends DatabaseAccessor<AppDatabase> with _$PlantsDaoMixin {
  PlantsDao(super.db);

  Future<List<PlantsTableData>> getAll() => (select(plantsTable)
        ..where((t) => t.deletedAt.isNull())
        ..orderBy([(t) => OrderingTerm.asc(t.nickname)]))
      .get();

  Stream<List<PlantsTableData>> watchAll() => (select(plantsTable)
        ..where((t) => t.deletedAt.isNull())
        ..orderBy([(t) => OrderingTerm.asc(t.nickname)]))
      .watch();

  Future<PlantsTableData?> getById(String id) =>
      (select(plantsTable)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> upsert(PlantsTableCompanion companion) =>
      into(plantsTable).insertOnConflictUpdate(companion);

  Future<void> updateLastIrrigated(String id, DateTime? when,
          {required DateTime updatedAt, required int rev}) =>
      (update(plantsTable)..where((t) => t.id.equals(id))).write(
        PlantsTableCompanion(
          lastIrrigatedAt: Value(when),
          updatedAt: Value(updatedAt),
          localRev: Value(rev),
          deviceId: Value(attachedDatabase.deviceId),
        ),
      );

  Future<void> updateLastPesticideApplication(
          String id, DateTime? appliedAt, int? reapplicationDays,
          {required DateTime updatedAt, required int rev}) =>
      (update(plantsTable)..where((t) => t.id.equals(id))).write(
        PlantsTableCompanion(
          lastPesticideAppliedAt: Value(appliedAt),
          pesticideReapplicationDays: Value(reapplicationDays),
          updatedAt: Value(updatedAt),
          localRev: Value(rev),
          deviceId: Value(attachedDatabase.deviceId),
        ),
      );

  Future<void> updateCoverPhoto(String id, String? photoId,
          {required DateTime updatedAt, required int rev}) =>
      (update(plantsTable)..where((t) => t.id.equals(id))).write(
        PlantsTableCompanion(
          coverPhotoId: Value(photoId),
          updatedAt: Value(updatedAt),
          localRev: Value(rev),
          deviceId: Value(attachedDatabase.deviceId),
        ),
      );

  Future<void> softDelete(String id,
          {required DateTime deletedAt, required int rev}) =>
      (update(plantsTable)..where((t) => t.id.equals(id))).write(
        PlantsTableCompanion(
          deletedAt: Value(deletedAt),
          updatedAt: Value(deletedAt),
          localRev: Value(rev),
          deviceId: Value(attachedDatabase.deviceId),
        ),
      );

  Future<List<PlantsTableData>> changesSince(int since,
          {required int limit}) =>
      (select(plantsTable)
            ..where((t) => t.localRev.isBiggerThanValue(since))
            ..orderBy([(t) => OrderingTerm.asc(t.localRev)])
            ..limit(limit))
          .get();

  Future<bool> hasActiveReferencingSpecies(String speciesId) async {
    final row = await (select(plantsTable)
          ..where((t) => t.speciesId.equals(speciesId) & t.deletedAt.isNull())
          ..limit(1))
        .getSingleOrNull();
    return row != null;
  }

  Future<bool> hasActiveReferencingSoil(String soilId) async {
    final row = await (select(plantsTable)
          ..where((t) => t.soilType.equals(soilId) & t.deletedAt.isNull())
          ..limit(1))
        .getSingleOrNull();
    return row != null;
  }

  /// Nulls out `locationId` on every active plant referencing [locationId]
  /// (replicating the `KeyAction.setNull` FK behavior that only fires on a
  /// real SQLite DELETE, which a soft-delete never triggers). Returns the
  /// affected plant ids so the caller can reschedule anything derived from
  /// them.
  Future<List<String>> clearLocationForPlants(String locationId,
      {required DateTime updatedAt, required int rev}) async {
    final rows = await (select(plantsTable)
          ..where(
              (t) => t.locationId.equals(locationId) & t.deletedAt.isNull()))
        .get();
    if (rows.isEmpty) return const [];
    await (update(plantsTable)..where((t) => t.locationId.equals(locationId)))
        .write(PlantsTableCompanion(
      locationId: const Value(null),
      updatedAt: Value(updatedAt),
      localRev: Value(rev),
      deviceId: Value(attachedDatabase.deviceId),
    ));
    return rows.map((r) => r.id).toList();
  }

  /// Live plants in the pot [potId].
  Future<List<PlantsTableData>> getByPot(String potId) => (select(plantsTable)
        ..where((t) => t.potId.equals(potId) & t.deletedAt.isNull())
        ..orderBy([(t) => OrderingTerm.asc(t.nickname)]))
      .get();

  /// Puts the plant in [potId] (null: out of any pot). With [locationId]
  /// present, also moves it there.
  Future<void> updatePot(String id, String? potId,
          {Value<String?> locationId = const Value.absent(),
          required DateTime updatedAt,
          required int rev}) =>
      (update(plantsTable)..where((t) => t.id.equals(id))).write(
        PlantsTableCompanion(
          potId: Value(potId),
          locationId: locationId,
          updatedAt: Value(updatedAt),
          localRev: Value(rev),
          deviceId: Value(attachedDatabase.deviceId),
        ),
      );

  Future<void> updateLocation(String id, String? locationId,
          {required DateTime updatedAt, required int rev}) =>
      (update(plantsTable)..where((t) => t.id.equals(id))).write(
        PlantsTableCompanion(
          locationId: Value(locationId),
          updatedAt: Value(updatedAt),
          localRev: Value(rev),
          deviceId: Value(attachedDatabase.deviceId),
        ),
      );
}
