import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import '../../../core/database/app_database.dart';
import '../../../core/database/converters.dart';

/// Serializes the active workspace's database (including soft-delete
/// tombstones, so a restored backup can't resurrect deleted rows on a live
/// database) plus the entry photo files into a single zip archive.
///
/// Row JSON mirrors the sync wire payloads in DriftSyncStorageAdapter, with
/// `updatedAt`/`deletedAt`/`deviceId` flattened in, so DataImportService can
/// merge a backup with the same LWW rule sync uses.
class DataExportService {
  DataExportService(this._db);

  final AppDatabase _db;

  static const formatName = 'polypodium-backup';
  static const formatVersion = 1;
  static const dataFileName = 'data.json';
  static const photosDirName = 'photos';

  static String suggestedFileName() {
    final now = DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    return 'polypodium-backup-${now.year}${two(now.month)}${two(now.day)}-'
        '${two(now.hour)}${two(now.minute)}${two(now.second)}.zip';
  }

  Future<Uint8List> buildArchiveBytes() async {
    final species = await _db.select(_db.speciesTable).get();
    final soils = await _db.select(_db.soilsTable).get();
    final locations = await _db.select(_db.locationsTable).get();
    final pots = await _db.select(_db.potsTable).get();
    final plants = await _db.select(_db.plantsTable).get();
    final entries = await _db.select(_db.entriesTable).get();
    final entryPhotos = await _db.select(_db.entryPhotosTable).get();
    final defensivos = await _db.select(_db.defensivosTable).get();
    final reminders = await _db.select(_db.remindersTable).get();

    final archive = Archive();
    final photoNames = <String>{};

    /// Adds the photo at [path] to the archive's photos/ folder and returns
    /// its name there, or null when the file is missing on disk.
    Future<String?> addPhoto(String path) async {
      final file = File(path);
      if (!file.existsSync()) return null;
      final photoFile = p.basename(path);
      if (photoNames.add(photoFile)) {
        final bytes = await file.readAsBytes();
        archive.addFile(
            ArchiveFile('$photosDirName/$photoFile', bytes.length, bytes));
      }
      return photoFile;
    }

    final entryMaps = <Map<String, dynamic>>[];
    for (final r in entries) {
      final path = r.photoPath;
      final photoFile =
          path != null && r.deletedAt == null ? await addPhoto(path) : null;
      entryMaps.add({
        'id': r.id,
        'plantId': r.plantId,
        'date': r.date.toIso8601String(),
        'photoPath': r.photoPath,
        // Name of this entry's photo inside the archive's photos/ folder,
        // null when the file was missing on disk at export time.
        'photoFile': photoFile,
        'note': r.note,
        'type': r.type.name,
        'numericValue': r.numericValue,
        'extraData': r.extraData,
        'createdAt': r.createdAt.toIso8601String(),
        'updatedAt': r.updatedAt.toIso8601String(),
        'deletedAt': r.deletedAt?.toIso8601String(),
        'deviceId': r.deviceId,
      });
    }

    final data = {
      'format': formatName,
      'version': formatVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'entities': {
        'species': [
          for (final r in species)
            {
              'id': r.id,
              'scientificName': r.scientificName,
              'popularName': r.popularName,
              'defaultIrrigationFrequencyDays':
                  r.defaultIrrigationFrequencyDays,
              'recommendedSoilIds': r.recommendedSoilTypes,
              'light': r.light?.name,
              'humidity': r.humidity?.name,
              'petToxicity': r.petToxicity.name,
              'floweringMonths': MonthSetConverter.toJson(r.floweringMonths),
              'careNotes': r.careNotes,
              'createdAt': r.createdAt.toIso8601String(),
              'updatedAt': r.updatedAt.toIso8601String(),
              'deletedAt': r.deletedAt?.toIso8601String(),
              'deviceId': r.deviceId,
            }
        ],
        'soils': [
          for (final r in soils)
            {
              'id': r.id,
              'name': r.name,
              'composition': r.composition,
              'imagePath': r.imagePath,
              'imageSource': r.imageSource,
              'isSeeded': r.isSeeded,
              'createdAt': r.createdAt.toIso8601String(),
              'updatedAt': r.updatedAt.toIso8601String(),
              'deletedAt': r.deletedAt?.toIso8601String(),
              'deviceId': r.deviceId,
            }
        ],
        'locations': [
          for (final r in locations)
            {
              'id': r.id,
              'name': r.name,
              'description': r.description,
              'latitude': r.latitude,
              'longitude': r.longitude,
              'createdAt': r.createdAt.toIso8601String(),
              'updatedAt': r.updatedAt.toIso8601String(),
              'deletedAt': r.deletedAt?.toIso8601String(),
              'deviceId': r.deviceId,
            }
        ],
        // Releases without pots skip the section, and the plants' potId.
        'pots': [
          for (final r in pots)
            {
              'id': r.id,
              'name': r.name,
              'kind': r.kind.name,
              'diameterCm': r.diameterCm,
              'material': r.material?.name,
              'locationId': r.locationId,
              'notes': r.notes,
              'createdAt': r.createdAt.toIso8601String(),
              'updatedAt': r.updatedAt.toIso8601String(),
              'deletedAt': r.deletedAt?.toIso8601String(),
              'deviceId': r.deviceId,
            }
        ],
        'plants': [
          for (final r in plants)
            {
              'id': r.id,
              'speciesId': r.speciesId,
              'nickname': r.nickname,
              'soilId': r.soilType,
              'irrigationFrequencyDays': r.irrigationFrequencyDays,
              'acquisitionDate': r.acquisitionDate.toIso8601String(),
              'locationId': r.locationId,
              'lastIrrigatedAt': r.lastIrrigatedAt?.toIso8601String(),
              'lastPesticideAppliedAt':
                  r.lastPesticideAppliedAt?.toIso8601String(),
              'pesticideReapplicationDays': r.pesticideReapplicationDays,
              'status': r.status.name,
              'statusChangedAt': r.statusChangedAt?.toIso8601String(),
              'parentPlantId': r.parentPlantId,
              'coverPhotoId': r.coverPhotoId,
              'potId': r.potId,
              'createdAt': r.createdAt.toIso8601String(),
              'updatedAt': r.updatedAt.toIso8601String(),
              'deletedAt': r.deletedAt?.toIso8601String(),
              'deviceId': r.deviceId,
            }
        ],
        'entries': entryMaps,
        // Photos of an entry after its first. Releases without them skip
        // the section and keep only each entry's first photo.
        'entryPhotos': [
          for (final r in entryPhotos)
            {
              'id': r.id,
              'entryId': r.entryId,
              'photoPath': r.photoPath,
              'photoFile':
                  r.deletedAt == null ? await addPhoto(r.photoPath) : null,
              'position': r.position,
              'createdAt': r.createdAt.toIso8601String(),
              'updatedAt': r.updatedAt.toIso8601String(),
              'deletedAt': r.deletedAt?.toIso8601String(),
              'deviceId': r.deviceId,
            }
        ],
        'defensivos': [
          for (final r in defensivos)
            {
              'id': r.id,
              'name': r.name,
              'category': r.category,
              'customCategoryLabel': r.customCategoryLabel,
              'composition': r.composition,
              'carenciaDays': r.carenciaDays,
              'imagePath': r.imagePath,
              'imageSource': r.imageSource,
              'createdAt': r.createdAt.toIso8601String(),
              'updatedAt': r.updatedAt.toIso8601String(),
              'deletedAt': r.deletedAt?.toIso8601String(),
              'deviceId': r.deviceId,
            }
        ],
        'reminders': [
          for (final r in reminders)
            {
              'id': r.id,
              'plantId': r.plantId,
              'entryType': r.entryType.name,
              'intervalDays': r.intervalDays,
              'enabled': r.enabled,
              'createdAt': r.createdAt.toIso8601String(),
              'updatedAt': r.updatedAt.toIso8601String(),
              'deletedAt': r.deletedAt?.toIso8601String(),
              'deviceId': r.deviceId,
            }
        ],
      },
    };

    final jsonBytes = utf8.encode(jsonEncode(data));
    archive.addFile(ArchiveFile(dataFileName, jsonBytes.length, jsonBytes));

    return Uint8List.fromList(ZipEncoder().encode(archive)!);
  }
}
