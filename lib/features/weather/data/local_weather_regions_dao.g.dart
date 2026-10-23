// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_weather_regions_dao.dart';

// ignore_for_file: type=lint
mixin _$LocalWeatherRegionsDaoMixin on DatabaseAccessor<AppDatabase> {
  $LocalWeatherRegionsTableTable get localWeatherRegionsTable =>
      attachedDatabase.localWeatherRegionsTable;
  LocalWeatherRegionsDaoManager get managers =>
      LocalWeatherRegionsDaoManager(this);
}

class LocalWeatherRegionsDaoManager {
  final _$LocalWeatherRegionsDaoMixin _db;
  LocalWeatherRegionsDaoManager(this._db);
  $$LocalWeatherRegionsTableTableTableManager get localWeatherRegionsTable =>
      $$LocalWeatherRegionsTableTableTableManager(
          _db.attachedDatabase, _db.localWeatherRegionsTable);
}
