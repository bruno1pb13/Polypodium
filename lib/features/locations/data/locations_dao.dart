import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';

part 'locations_dao.g.dart';

@DriftAccessor(tables: [LocationsTable])
class LocationsDao extends DatabaseAccessor<AppDatabase>
    with _$LocationsDaoMixin {
  LocationsDao(super.db);

  Future<List<LocationsTableData>> getAll() => (select(locationsTable)
        ..where((t) => t.deletedAt.isNull())
        ..orderBy([(t) => OrderingTerm.asc(t.name)]))
      .get();

  Stream<List<LocationsTableData>> watchAll() => (select(locationsTable)
        ..where((t) => t.deletedAt.isNull())
        ..orderBy([(t) => OrderingTerm.asc(t.name)]))
      .watch();

  Future<LocationsTableData?> getById(String id) =>
      (select(locationsTable)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> upsert(LocationsTableCompanion companion) =>
      into(locationsTable).insertOnConflictUpdate(companion);

  Future<void> softDelete(String id,
          {required DateTime deletedAt, required int rev}) =>
      (update(locationsTable)..where((t) => t.id.equals(id))).write(
        LocationsTableCompanion(
          deletedAt: Value(deletedAt),
          updatedAt: Value(deletedAt),
          localRev: Value(rev),
        ),
      );

  /// Maps a legacy free-text plant location (from before locations were
  /// their own entity) to a location id, reusing a live location with the
  /// same name (case-insensitive) or creating one. A created id is derived
  /// from the name, so devices resolving the same text converge on a single
  /// row instead of syncing duplicates. Returns null for blank text. Must run
  /// inside the caller's transaction, since it may stamp a new revision.
  Future<String?> resolveLegacyName(String? text) async {
    final name = text?.trim() ?? '';
    if (name.isEmpty) return null;
    final key = name.toLowerCase();
    for (final row in await getAll()) {
      if (row.name.trim().toLowerCase() == key) return row.id;
    }
    final id = const Uuid()
        .v5(Namespace.url.value, 'polypodium:legacy-location:$key');
    final now = DateTime.now();
    final rev = await attachedDatabase.syncMetaDao.nextRev();
    await upsert(LocationsTableCompanion.insert(
      id: id,
      name: name,
      createdAt: now,
      updatedAt: now,
      // Revives the derived row if it was soft-deleted in the meantime.
      deletedAt: const Value(null),
      localRev: Value(rev),
    ));
    return id;
  }

  Future<List<LocationsTableData>> changesSince(int since,
          {required int limit}) =>
      (select(locationsTable)
            ..where((t) => t.localRev.isBiggerThanValue(since))
            ..orderBy([(t) => OrderingTerm.asc(t.localRev)])
            ..limit(limit))
          .get();
}
