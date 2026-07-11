import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/enums.dart';
import '../../../core/storage/photo_storage.dart';
import '../../../core/sync/lww_merge.dart';
import 'data_export_service.dart';

class ImportSummary {
  const ImportSummary({required this.applied, required this.skipped});

  /// Rows written to the database.
  final int applied;

  /// Rows ignored because the local copy was newer (same LWW rule as sync).
  final int skipped;
}

/// Why the selected file could not be imported. The UI maps each kind to a
/// localized message.
enum InvalidBackupKind {
  /// Structurally broken data (missing sections, bad rows, decode failures).
  corrupt,

  /// Not a .zip/.json backup file, or a zip without data.json.
  unrecognized,

  /// A readable file that is not a Polypodium backup.
  notPolypodiumBackup,

  /// Produced by a newer app version than this one understands.
  newerVersion,
}

/// Thrown when the selected file is not a readable Polypodium backup.
/// [detail] is diagnostic only, never shown to the user.
class InvalidBackupException implements Exception {
  const InvalidBackupException(this.kind, [this.detail]);
  final InvalidBackupKind kind;
  final String? detail;

  @override
  String toString() =>
      'InvalidBackupException($kind${detail == null ? '' : ': $detail'})';
}

/// Merges a backup produced by DataExportService into the active workspace.
///
/// Rows are merged with the same last-write-wins rule sync uses (a strictly
/// older backup row never overwrites newer local data) and every applied row
/// is stamped with a fresh localRev, so on a remote workspace the imported
/// data is pushed to the server on the next sync.
class DataImportService {
  DataImportService(this._db, this._photos);

  final AppDatabase _db;
  final PhotoStorage _photos;

  Future<ImportSummary> importFromBytes(Uint8List bytes) async {
    final parsed = _parseArchive(bytes);
    final entities = parsed.data['entities'];
    if (entities is! Map<String, dynamic>) {
      throw const InvalidBackupException(
          InvalidBackupKind.corrupt, 'missing entities section');
    }

    List<Map<String, dynamic>> rowsOf(String key) {
      final list = entities[key];
      if (list == null) return const [];
      return (list as List<dynamic>).cast<Map<String, dynamic>>();
    }

    // Photos are written before the transaction because the rewritten
    // photoPath must be known at upsert time. If the transaction fails, the
    // stray files are reclaimed by the existing orphan-photo cleanup.
    final entryRows = rowsOf('entries');
    final photoPaths = <String, String>{};
    for (final row in entryRows) {
      final photoFile = row['photoFile'] as String?;
      if (photoFile == null) continue;
      final fileBytes = parsed.photos[photoFile];
      if (fileBytes == null) continue;
      photoPaths[photoFile] = await _photos.restorePhoto(fileBytes, photoFile);
    }

    var applied = 0;
    var skipped = 0;
    final irrigatedPlantIds = <String>{};

    try {
      await _db.transaction(() async {
        // FK-dependency order, same as sync replay.
        for (final row in rowsOf('species')) {
          if (await _applySpecies(row)) {
            applied++;
          } else {
            skipped++;
          }
        }
        for (final row in rowsOf('soils')) {
          if (await _applySoil(row)) {
            applied++;
          } else {
            skipped++;
          }
        }
        for (final row in rowsOf('locations')) {
          if (await _applyLocation(row)) {
            applied++;
          } else {
            skipped++;
          }
        }
        for (final row in rowsOf('plants')) {
          if (await _applyPlant(row)) {
            applied++;
          } else {
            skipped++;
          }
        }
        for (final row in entryRows) {
          if (await _applyEntry(row, photoPaths)) {
            applied++;
            if (row['deletedAt'] == null &&
                row['type'] == EntryType.irrigation.name) {
              irrigatedPlantIds.add(row['plantId'] as String);
            }
          } else {
            skipped++;
          }
        }

        // Imported irrigation entries may change a plant's irrigation
        // history; recompute the derived lastIrrigatedAt as a fresh local
        // write, mirroring DriftSyncStorageAdapter._applyEntry.
        for (final plantId in irrigatedPlantIds) {
          if (await _db.plantsDao.getById(plantId) == null) continue;
          final lastDate = await _db.entriesDao.getLastIrrigationDate(plantId);
          final rev = await _db.syncMetaDao.nextRev();
          await _db.plantsDao.updateLastIrrigated(plantId, lastDate,
              updatedAt: DateTime.now(), rev: rev);
        }
      });
    } on InvalidBackupException {
      rethrow;
    } catch (e) {
      throw InvalidBackupException(InvalidBackupKind.corrupt, '$e');
    }

    return ImportSummary(applied: applied, skipped: skipped);
  }

  ({Map<String, dynamic> data, Map<String, Uint8List> photos}) _parseArchive(
      Uint8List bytes) {
    String? jsonText;
    final photos = <String, Uint8List>{};

    Archive? archive;
    try {
      archive = ZipDecoder().decodeBytes(bytes, verify: true);
    } catch (_) {
      archive = null;
    }

    if (archive != null) {
      for (final file in archive.files) {
        if (!file.isFile) continue;
        if (file.name == DataExportService.dataFileName) {
          jsonText = utf8.decode(file.content as List<int>);
        } else if (file.name
            .startsWith('${DataExportService.photosDirName}/')) {
          final name = file.name
              .substring(DataExportService.photosDirName.length + 1);
          photos[name] = Uint8List.fromList(file.content as List<int>);
        }
      }
      if (jsonText == null) {
        throw const InvalidBackupException(
            InvalidBackupKind.unrecognized, 'zip without data.json');
      }
    } else {
      // Also accept the bare data.json for hand-carried/edited backups.
      try {
        jsonText = utf8.decode(bytes);
      } catch (_) {
        throw const InvalidBackupException(InvalidBackupKind.unrecognized);
      }
    }

    final Object? decoded;
    try {
      decoded = jsonDecode(jsonText);
    } on FormatException {
      throw const InvalidBackupException(InvalidBackupKind.unrecognized);
    }
    if (decoded is! Map<String, dynamic> ||
        decoded['format'] != DataExportService.formatName) {
      throw const InvalidBackupException(
          InvalidBackupKind.notPolypodiumBackup);
    }
    final version = decoded['version'];
    if (version is! int || version > DataExportService.formatVersion) {
      throw const InvalidBackupException(InvalidBackupKind.newerVersion);
    }
    return (data: decoded, photos: photos);
  }

  // -- per-entity appliers ---------------------------------------------------

  DateTime _updatedAt(Map<String, dynamic> row) =>
      DateTime.parse(row['updatedAt'] as String);

  DateTime? _deletedAt(Map<String, dynamic> row) => row['deletedAt'] != null
      ? DateTime.parse(row['deletedAt'] as String)
      : null;

  Future<bool> _applySpecies(Map<String, dynamic> row) async {
    final existing = await _db.speciesDao.getById(row['id'] as String);
    final updatedAt = _updatedAt(row);
    if (!shouldApplyRemote(
        localUpdatedAt: existing?.updatedAt, remoteUpdatedAt: updatedAt)) {
      return false;
    }
    final rev = await _db.syncMetaDao.nextRev();
    await _db.speciesDao.upsert(SpeciesTableCompanion.insert(
      id: row['id'] as String,
      scientificName: row['scientificName'] as String,
      popularName: row['popularName'] as String,
      defaultIrrigationFrequencyDays:
          Value(row['defaultIrrigationFrequencyDays'] as int?),
      recommendedSoilTypes:
          (row['recommendedSoilIds'] as List<dynamic>?)?.cast<String>() ?? [],
      createdAt: DateTime.parse(row['createdAt'] as String),
      updatedAt: updatedAt,
      deletedAt: Value(_deletedAt(row)),
      localRev: Value(rev),
    ));
    return true;
  }

  Future<bool> _applySoil(Map<String, dynamic> row) async {
    final existing = await _db.soilsDao.getSoilById(row['id'] as String);
    final updatedAt = _updatedAt(row);
    if (!shouldApplyRemote(
        localUpdatedAt: existing?.updatedAt, remoteUpdatedAt: updatedAt)) {
      return false;
    }
    final rev = await _db.syncMetaDao.nextRev();
    await _db.soilsDao.insertSoil(SoilsTableCompanion.insert(
      id: row['id'] as String,
      name: row['name'] as String,
      composition: Value(row['composition'] as String?),
      imagePath: Value(row['imagePath'] as String?),
      imageSource: Value(row['imageSource'] as String?),
      isSeeded: Value(row['isSeeded'] as bool? ?? false),
      createdAt: DateTime.parse(row['createdAt'] as String),
      updatedAt: updatedAt,
      deletedAt: Value(_deletedAt(row)),
      localRev: Value(rev),
    ));
    return true;
  }

  Future<bool> _applyLocation(Map<String, dynamic> row) async {
    final existing = await _db.locationsDao.getById(row['id'] as String);
    final updatedAt = _updatedAt(row);
    if (!shouldApplyRemote(
        localUpdatedAt: existing?.updatedAt, remoteUpdatedAt: updatedAt)) {
      return false;
    }
    final rev = await _db.syncMetaDao.nextRev();
    await _db.locationsDao.upsert(LocationsTableCompanion.insert(
      id: row['id'] as String,
      name: row['name'] as String,
      description: Value(row['description'] as String?),
      latitude: Value((row['latitude'] as num?)?.toDouble()),
      longitude: Value((row['longitude'] as num?)?.toDouble()),
      createdAt: DateTime.parse(row['createdAt'] as String),
      updatedAt: updatedAt,
      deletedAt: Value(_deletedAt(row)),
      localRev: Value(rev),
    ));
    return true;
  }

  Future<bool> _applyPlant(Map<String, dynamic> row) async {
    final existing = await _db.plantsDao.getById(row['id'] as String);
    final updatedAt = _updatedAt(row);
    if (!shouldApplyRemote(
        localUpdatedAt: existing?.updatedAt, remoteUpdatedAt: updatedAt)) {
      return false;
    }
    final rev = await _db.syncMetaDao.nextRev();
    await _db.plantsDao.upsert(PlantsTableCompanion.insert(
      id: row['id'] as String,
      speciesId: row['speciesId'] as String,
      nickname: row['nickname'] as String,
      soilType: row['soilId'] as String,
      irrigationFrequencyDays: Value(row['irrigationFrequencyDays'] as int?),
      acquisitionDate: DateTime.parse(row['acquisitionDate'] as String),
      location: Value(row['location'] as String?),
      locationId: Value(row['locationId'] as String?),
      lastIrrigatedAt: Value(row['lastIrrigatedAt'] != null
          ? DateTime.parse(row['lastIrrigatedAt'] as String)
          : null),
      createdAt: DateTime.parse(row['createdAt'] as String),
      updatedAt: updatedAt,
      deletedAt: Value(_deletedAt(row)),
      localRev: Value(rev),
    ));
    return true;
  }

  Future<bool> _applyEntry(
      Map<String, dynamic> row, Map<String, String> photoPaths) async {
    final existing = await _db.entriesDao.getById(row['id'] as String);
    final updatedAt = _updatedAt(row);
    if (!shouldApplyRemote(
        localUpdatedAt: existing?.updatedAt, remoteUpdatedAt: updatedAt)) {
      return false;
    }
    // Prefer the photo restored from the archive; fall back to the exported
    // path, which still resolves when restoring on the same device.
    final photoFile = row['photoFile'] as String?;
    final photoPath =
        (photoFile != null ? photoPaths[photoFile] : null) ??
            row['photoPath'] as String?;
    final rev = await _db.syncMetaDao.nextRev();
    await _db.entriesDao.upsert(EntriesTableCompanion.insert(
      id: row['id'] as String,
      plantId: row['plantId'] as String,
      date: DateTime.parse(row['date'] as String),
      photoPath: Value(photoPath),
      note: Value(row['note'] as String?),
      type: EntryType.values.byName(row['type'] as String),
      numericValue: Value((row['numericValue'] as num?)?.toDouble()),
      extraData: Value(row['extraData'] as String?),
      createdAt: DateTime.parse(row['createdAt'] as String),
      updatedAt: updatedAt,
      deletedAt: Value(_deletedAt(row)),
      localRev: Value(rev),
    ));
    return true;
  }
}
