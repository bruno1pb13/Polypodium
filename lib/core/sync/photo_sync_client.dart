import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

import '../storage/photo_storage.dart';

/// Handles the entry-photo side channel: local files never travel inside
/// the JSON change payload, only a `photoKey` reference does. Kept
/// separate from the storage adapter (which only knows about local file
/// paths) and the orchestrator (which only knows about swapping payload
/// fields), so a failed upload/download can't corrupt the rest of a batch.
class PhotoSyncClient {
  const PhotoSyncClient(this._photoStorage);

  final PhotoStorage _photoStorage;

  /// Uploads [localPath] and returns the photo key, or null on failure (in
  /// which case the caller should skip this change and retry next sync).
  Future<String?> upload({
    required String serverUrl,
    required String token,
    required String entityId,
    required String localPath,
  }) async {
    try {
      final file = File(localPath);
      if (!file.existsSync()) return null;
      final ext = p.extension(localPath);
      final photoKey = '$entityId$ext';
      final bytes = await file.readAsBytes();
      final response = await http
          .put(
            Uri.parse('$serverUrl/api/v1/photos/$photoKey'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/octet-stream',
            },
            body: bytes,
          )
          .timeout(const Duration(seconds: 60));
      return response.statusCode == 200 ? photoKey : null;
    } catch (_) {
      return null;
    }
  }

  /// Downloads [photoKey] and saves it locally, returning the local path,
  /// or null on failure.
  Future<String?> download({
    required String serverUrl,
    required String token,
    required String photoKey,
  }) async {
    try {
      final response = await http
          .get(
            Uri.parse('$serverUrl/api/v1/photos/$photoKey'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 60));
      if (response.statusCode != 200) return null;
      return await _photoStorage.savePhotoBytes(response.bodyBytes, photoKey);
    } catch (_) {
      return null;
    }
  }
}
