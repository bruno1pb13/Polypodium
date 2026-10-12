import 'dart:io';
import 'dart:isolate';

import 'package:path/path.dart' as p;

import '../domain/workspace_model.dart';
import '../domain/workspace_paths.dart';

/// Bytes a workspace takes on this device.
class WorkspaceDiskUsage {
  final int database;
  final int photos;

  const WorkspaceDiskUsage({required this.database, required this.photos});

  int get total => database + photos;
}

/// Measures [workspace]'s database (SQLite's side files included) and photo
/// folder under [documentsDir]. Runs in an isolate: a garden with thousands
/// of photos means walking thousands of files.
Future<WorkspaceDiskUsage> measureDiskUsage(
    Workspace workspace, String documentsDir) {
  final dbPath = p.join(documentsDir, dbFileNameFor(workspace));
  final photosPath = p.join(documentsDir, photoDirNameFor(workspace));
  return Isolate.run(() => WorkspaceDiskUsage(
        database: [
          dbPath,
          '$dbPath-wal',
          '$dbPath-shm',
          '$dbPath-journal',
        ].fold(0, (sum, path) => sum + _fileSize(path)),
        photos: _dirSize(photosPath),
      ));
}

int _fileSize(String path) {
  final file = File(path);
  return file.existsSync() ? file.lengthSync() : 0;
}

int _dirSize(String path) {
  final dir = Directory(path);
  if (!dir.existsSync()) return 0;
  var total = 0;
  for (final entity in dir.listSync(recursive: true, followLinks: false)) {
    if (entity is File) total += entity.lengthSync();
  }
  return total;
}
