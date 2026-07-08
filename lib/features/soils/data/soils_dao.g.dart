// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'soils_dao.dart';

// ignore_for_file: type=lint
mixin _$SoilsDaoMixin on DatabaseAccessor<AppDatabase> {
  $SoilsTableTable get soilsTable => attachedDatabase.soilsTable;
  SoilsDaoManager get managers => SoilsDaoManager(this);
}

class SoilsDaoManager {
  final _$SoilsDaoMixin _db;
  SoilsDaoManager(this._db);
  $$SoilsTableTableTableManager get soilsTable =>
      $$SoilsTableTableTableManager(_db.attachedDatabase, _db.soilsTable);
}
