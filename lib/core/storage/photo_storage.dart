import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class PhotoStorage {
  static Future<Directory> _photosDir() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(base.path, 'plant_photos'));
    if (!dir.existsSync()) await dir.create(recursive: true);
    return dir;
  }

  /// Copies [sourceFile] into app storage and returns the saved path.
  Future<String> savePhoto(File sourceFile) async {
    final dir = await _photosDir();
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}${p.extension(sourceFile.path)}';
    final dest = File(p.join(dir.path, fileName));
    await sourceFile.copy(dest.path);
    return dest.path;
  }

  Future<void> deletePhoto(String path) async {
    final file = File(path);
    if (file.existsSync()) await file.delete();
  }

  /// Removes photo files whose paths are not in [referencedPaths].
  Future<void> cleanOrphanPhotos(List<String> referencedPaths) async {
    final dir = await _photosDir();
    final referenced = referencedPaths.toSet();
    await for (final entity in dir.list()) {
      if (entity is File && !referenced.contains(entity.path)) {
        await entity.delete();
      }
    }
  }
}
