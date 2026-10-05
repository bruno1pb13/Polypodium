import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

/// Picks photos from the camera or the gallery. Behind a provider so tests
/// can stand in for the platform picker.
class PhotoPicker {
  const PhotoPicker();

  /// Paths of up to [limit] picked photos (the camera takes one); empty when
  /// the user cancels.
  Future<List<String>> pick(ImageSource source, {int limit = 1}) async {
    final picker = ImagePicker();
    // The multi-picker refuses a limit below 2.
    if (source == ImageSource.gallery && limit > 1) {
      final files = await picker.pickMultiImage(imageQuality: 85, limit: limit);
      return [for (final f in files.take(limit)) f.path];
    }
    final file = await picker.pickImage(source: source, imageQuality: 85);
    return file == null ? const [] : [file.path];
  }
}

final photoPickerProvider = Provider<PhotoPicker>((ref) => const PhotoPicker());
