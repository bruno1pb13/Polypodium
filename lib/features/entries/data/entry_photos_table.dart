import 'package:drift/drift.dart';

import 'entries_table.dart';

/// Photos of an entry after the first, which stays in `entries.photo_path`
/// so releases that only know that column still show it. Synced as their
/// own `entry_photo` entity, which those releases ignore.
class EntryPhotosTable extends Table {
  @override
  String get tableName => 'entry_photos';

  TextColumn get id => text()();
  TextColumn get entryId =>
      text().references(EntriesTable, #id, onDelete: KeyAction.cascade)();
  TextColumn get photoPath => text()();

  /// Order within the entry; the entry's own photo comes before all of them.
  IntColumn get position => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get localRev => integer().withDefault(const Constant(0))();
  TextColumn get deviceId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
