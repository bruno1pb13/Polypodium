// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_meta_dao.dart';

// ignore_for_file: type=lint
mixin _$SyncMetaDaoMixin on DatabaseAccessor<AppDatabase> {
  $SyncMetaTableTable get syncMetaTable => attachedDatabase.syncMetaTable;
  SyncMetaDaoManager get managers => SyncMetaDaoManager(this);
}

class SyncMetaDaoManager {
  final _$SyncMetaDaoMixin _db;
  SyncMetaDaoManager(this._db);
  $$SyncMetaTableTableTableManager get syncMetaTable =>
      $$SyncMetaTableTableTableManager(_db.attachedDatabase, _db.syncMetaTable);
}
