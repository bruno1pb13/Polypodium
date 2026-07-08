// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'locations_dao.dart';

// ignore_for_file: type=lint
mixin _$LocationsDaoMixin on DatabaseAccessor<AppDatabase> {
  $LocationsTableTable get locationsTable => attachedDatabase.locationsTable;
  LocationsDaoManager get managers => LocationsDaoManager(this);
}

class LocationsDaoManager {
  final _$LocationsDaoMixin _db;
  LocationsDaoManager(this._db);
  $$LocationsTableTableTableManager get locationsTable =>
      $$LocationsTableTableTableManager(
          _db.attachedDatabase, _db.locationsTable);
}
