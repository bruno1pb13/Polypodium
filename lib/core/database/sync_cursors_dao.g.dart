// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_cursors_dao.dart';

// ignore_for_file: type=lint
mixin _$SyncCursorsDaoMixin on DatabaseAccessor<AppDatabase> {
  $SyncCursorsTableTable get syncCursorsTable =>
      attachedDatabase.syncCursorsTable;
  SyncCursorsDaoManager get managers => SyncCursorsDaoManager(this);
}

class SyncCursorsDaoManager {
  final _$SyncCursorsDaoMixin _db;
  SyncCursorsDaoManager(this._db);
  $$SyncCursorsTableTableTableManager get syncCursorsTable =>
      $$SyncCursorsTableTableTableManager(
          _db.attachedDatabase, _db.syncCursorsTable);
}
