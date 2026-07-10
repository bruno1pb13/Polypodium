import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class PhotoStorage {
  PhotoStorage({this.baseDirName = 'plant_photos'});

  /// Subfolder of the app documents directory this instance reads/writes,
  /// so each workspace can keep its photos isolated from the others.
  final String baseDirName;

  Future<Directory> _photosDir() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(base.path, baseDirName));
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

  /// Saves raw [bytes] as a new photo file and returns the saved path.
  Future<String> savePhotoBytes(List<int> bytes, String fileName) async {
    final dir = await _photosDir();
    final ext = p.extension(fileName);
    final name = '${DateTime.now().millisecondsSinceEpoch}$ext';
    final dest = File(p.join(dir.path, name));
    await dest.writeAsBytes(bytes);
    return dest.path;
  }

  /// Writes [bytes] under [fileName] (basename only) in this workspace's
  /// photo dir, reusing an existing file of the same name so repeated
  /// imports of the same backup stay idempotent. Returns the absolute path.
  Future<String> restorePhoto(List<int> bytes, String fileName) async {
    final dir = await _photosDir();
    final dest = File(p.join(dir.path, p.basename(fileName)));
    if (!dest.existsSync()) await dest.writeAsBytes(bytes);
    return dest.path;
  }

  /// Removes photo files whose paths are not in [referencedPaths].
  Future<void> cleanOrphanPhotos(List<String> referencedPaths) async {
    final dir = await _photosDir();
    // Compara por basename para evitar falsos positivos causados por
    // diferenças de resolução de symlinks entre chamadas (ex: Android).
    final referenced = referencedPaths.map(p.basename).toSet();
    await for (final entity in dir.list()) {
      if (entity is File && !referenced.contains(p.basename(entity.path))) {
        await entity.delete();
      }
    }
  }
}
