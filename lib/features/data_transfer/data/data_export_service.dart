import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import '../../../core/database/app_database.dart';

/// Serializes the active workspace's database (including soft-delete
/// tombstones, so a restored backup can't resurrect deleted rows on a live
/// database) plus the entry photo files into a single zip archive.
///
/// Row JSON mirrors the sync wire payloads in DriftSyncStorageAdapter, with
/// `updatedAt`/`deletedAt` flattened in, so DataImportService can merge a
/// backup with the same LWW rule sync uses.
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
    final plants = await _db.select(_db.plantsTable).get();
    final entries = await _db.select(_db.entriesTable).get();

    final archive = Archive();
    final photoNames = <String>{};

    final entryMaps = <Map<String, dynamic>>[];
    for (final r in entries) {
      String? photoFile;
      final path = r.photoPath;
      if (path != null && r.deletedAt == null) {
        final file = File(path);
        if (file.existsSync()) {
          photoFile = p.basename(path);
          if (photoNames.add(photoFile)) {
            final bytes = await file.readAsBytes();
            archive.addFile(
                ArchiveFile('$photosDirName/$photoFile', bytes.length, bytes));
          }
        }
      }
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
              'createdAt': r.createdAt.toIso8601String(),
              'updatedAt': r.updatedAt.toIso8601String(),
              'deletedAt': r.deletedAt?.toIso8601String(),
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
              'location': r.location,
              'locationId': r.locationId,
              'lastIrrigatedAt': r.lastIrrigatedAt?.toIso8601String(),
              'createdAt': r.createdAt.toIso8601String(),
              'updatedAt': r.updatedAt.toIso8601String(),
              'deletedAt': r.deletedAt?.toIso8601String(),
            }
        ],
        'entries': entryMaps,
      },
    };

    final jsonBytes = utf8.encode(jsonEncode(data));
    archive.addFile(ArchiveFile(dataFileName, jsonBytes.length, jsonBytes));

    return Uint8List.fromList(ZipEncoder().encode(archive)!);
  }
}
