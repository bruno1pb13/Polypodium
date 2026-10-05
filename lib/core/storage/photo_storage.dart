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

  /// A new file in [dir] named after the current time. Several photos saved
  /// within the same millisecond (one entry's photos, copied for each plant
  /// of a bulk entry) get a suffix instead of overwriting each other.
  File _newFile(Directory dir, String ext) {
    final stamp = DateTime.now().millisecondsSinceEpoch;
    var dest = File(p.join(dir.path, '$stamp$ext'));
    for (var i = 1; dest.existsSync(); i++) {
      dest = File(p.join(dir.path, '${stamp}_$i$ext'));
    }
    return dest;
  }

  /// Copies [sourceFile] into app storage and returns the saved path.
  Future<String> savePhoto(File sourceFile) async {
    final dir = await _photosDir();
    final dest = _newFile(dir, p.extension(sourceFile.path));
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
    final dest = _newFile(dir, p.extension(fileName));
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
