import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';

part 'local_weather_regions_dao.g.dart';

@DriftAccessor(tables: [LocalWeatherRegionsTable])
class LocalWeatherRegionsDao extends DatabaseAccessor<AppDatabase>
    with _$LocalWeatherRegionsDaoMixin {
  LocalWeatherRegionsDao(super.db);

  Future<List<LocalWeatherRegionsTableData>> getAll() =>
      select(localWeatherRegionsTable).get();

  Stream<List<LocalWeatherRegionsTableData>> watchAll() =>
      select(localWeatherRegionsTable).watch();

  Future<void> upsert(LocalWeatherRegionsTableCompanion companion) =>
      into(localWeatherRegionsTable).insertOnConflictUpdate(companion);

  Future<void> deleteIds(Iterable<String> ids) =>
      (delete(localWeatherRegionsTable)..where((t) => t.id.isIn(ids))).go();

  Future<void> clear() => delete(localWeatherRegionsTable).go();
}
