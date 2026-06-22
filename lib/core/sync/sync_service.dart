import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../database/app_database.dart';
import '../enums.dart';
import '../storage/photo_storage.dart';

class SyncResult {
  final int pulled;
  final int pushed;
  const SyncResult({required this.pulled, required this.pushed});
}

class SyncService {
  SyncService(this._db, this._prefs, this._photoStorage);

  final AppDatabase _db;
  final SharedPreferences _prefs;
  final PhotoStorage _photoStorage;

  static const _tokenKey = 'sync_token';
  static const _deviceIdKey = 'sync_device_id';
  static const _cursorKey = 'sync_cursor';
  static const _serverUrlKey = 'sync_server_url';
  static const _lastSyncAtKey = 'sync_last_at';
  static const _userEmailKey = 'sync_user_email';

  String? get token => _prefs.getString(_tokenKey);
  String? get deviceId => _prefs.getString(_deviceIdKey);
  String? get serverUrl => _prefs.getString(_serverUrlKey);
  int get cursor => _prefs.getInt(_cursorKey) ?? 0;
  String? get userEmail => _prefs.getString(_userEmailKey);
  bool get isLoggedIn {
    try {
      return token != null && serverUrl != null;
    } catch (_) {
      return false;
    }
  }

  DateTime? get lastSyncAt {
    final s = _prefs.getString(_lastSyncAtKey);
    return s != null ? DateTime.tryParse(s) : null;
  }

  Map<String, String> get _authHeaders => {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

  Future<void> checkServer(String serverUrl) async {
    final response = await http
        .get(Uri.parse('$serverUrl/api/v1/health'))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Servidor não disponível ou URL inválida');
    }
  }

  Future<void> login(String serverUrl, String email, String password) async {
    final id = deviceId ?? const Uuid().v4();
    final response = await http
        .post(
          Uri.parse('$serverUrl/api/v1/auth/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': email,
            'password': password,
            'deviceId': id,
            'deviceName': 'Polypodium',
          }),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(body['message'] ?? 'Falha ao autenticar');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    await _prefs.setString(_tokenKey, data['token'] as String);
    await _prefs.setString(_deviceIdKey, data['deviceId'] as String);
    await _prefs.setString(_serverUrlKey, serverUrl);
    await _prefs.setString(_userEmailKey, email);
  }

  Future<void> logout() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_cursorKey);
    await _prefs.remove(_userEmailKey);
    await _prefs.remove(_lastSyncAtKey);
  }

  Future<SyncResult> sync() async {
    if (!isLoggedIn) throw Exception('Não autenticado');
    final pulled = await _pull();
    final pushed = await _push();
    await _prefs.setString(_lastSyncAtKey, DateTime.now().toIso8601String());
    return SyncResult(pulled: pulled, pushed: pushed);
  }

  // ---------------------------------------------------------------------------

  Future<int> _pull() async {
    var totalPulled = 0;
    var since = cursor;

    while (true) {
      final response = await http
          .get(
            Uri.parse('$serverUrl/api/v1/sync/pull?since=$since&limit=100'),
            headers: _authHeaders,
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 401) {
        throw Exception('Sessão expirada. Faça login novamente.');
      }
      if (response.statusCode != 200) {
        throw Exception('Erro ao receber dados do servidor');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final events = data['events'] as List<dynamic>;
      final nextCursor = data['nextCursor'] as int;
      final hasMore = data['hasMore'] as bool? ?? false;

      for (final event in events) {
        await _applyEvent(event as Map<String, dynamic>);
      }
      totalPulled += events.length;

      if (events.isNotEmpty) {
        await http
            .post(
              Uri.parse('$serverUrl/api/v1/sync/ack'),
              headers: _authHeaders,
              body: jsonEncode({'deviceId': deviceId, 'cursor': nextCursor}),
            )
            .timeout(const Duration(seconds: 10));
        await _prefs.setInt(_cursorKey, nextCursor);
        since = nextCursor;
      }

      if (!hasMore) break;
    }

    return totalPulled;
  }

  Future<int> _push() async {
    await _bootstrapPending();
    final pending = await _db.syncQueueDao.getPending();
    if (pending.isEmpty) return 0;

    final events = <Map<String, dynamic>>[];
    for (final item in pending) {
      Map<String, dynamic> payload;
      try {
        payload = jsonDecode(item.payload) as Map<String, dynamic>;
      } catch (_) {
        payload = {'raw': item.payload};
      }

      if (item.entityType == 'entry' &&
          item.operation != 'delete' &&
          payload['photoPath'] != null) {
        final localPath = payload['photoPath'] as String;
        payload.remove('photoPath');
        final photoKey = await _uploadPhoto(item.entityId, localPath);
        if (photoKey == null) {
          continue; // upload falhou — deixa na fila para retry
        }
        payload['photoKey'] = photoKey;
      }

      events.add({
        'localQueueId': item.id,
        'entityType': item.entityType,
        'entityId': item.entityId,
        'operation': item.operation,
        'payload': payload,
        'clientTimestamp': item.createdAt.toIso8601String(),
      });
    }

    final response = await http
        .post(
          Uri.parse('$serverUrl/api/v1/sync/push'),
          headers: _authHeaders,
          body: jsonEncode({'deviceId': deviceId, 'events': events}),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 401) {
      throw Exception('Sessão expirada. Faça login novamente.');
    }
    if (response.statusCode != 200) {
      throw Exception('Erro ao enviar dados para o servidor');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final accepted = (data['accepted'] as List<dynamic>).cast<int>().toSet();

    for (final item in pending) {
      if (accepted.contains(item.id)) {
        await _db.syncQueueDao.markProcessed(item.id);
        await _markEntitySynced(item.entityType, item.entityId);
      }
    }

    return accepted.length;
  }

  Future<void> _markEntitySynced(String entityType, String entityId) async {
    switch (entityType) {
      case 'plant':
        await _db.plantsDao.updateSyncStatus(entityId, SyncStatus.synced);
      case 'species':
        await _db.speciesDao.updateSyncStatus(entityId, SyncStatus.synced);
      case 'entry':
        await _db.entriesDao.updateSyncStatus(entityId, SyncStatus.synced);
      case 'location':
        await _db.locationsDao.updateSyncStatus(entityId, SyncStatus.synced);
      case 'soil':
        await _db.soilsDao.updateSyncStatus(entityId, SyncStatus.synced);
    }
  }

  /// Uploads a local photo to the server and returns the photo key, or null on failure.
  Future<String?> _uploadPhoto(String entryId, String localPath) async {
    try {
      final file = File(localPath);
      if (!file.existsSync()) return null;
      final ext = p.extension(localPath);
      final photoKey = '$entryId$ext';
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

  /// Downloads a photo from the server and saves it locally, returning the local path.
  Future<String?> _downloadPhoto(String photoKey) async {
    try {
      final response = await http
          .get(
            Uri.parse('$serverUrl/api/v1/photos/$photoKey'),
            headers: _authHeaders,
          )
          .timeout(const Duration(seconds: 60));
      if (response.statusCode != 200) return null;
      return await _photoStorage.savePhotoBytes(response.bodyBytes, photoKey);
    } catch (_) {
      return null;
    }
  }

  // ---------------------------------------------------------------------------

  Future<void> _applyEvent(Map<String, dynamic> event) async {
    final entityType = event['entityType'] as String;
    final operation = event['operation'] as String;
    final payload = event['payload'] as Map<String, dynamic>;

    switch (entityType) {
      case 'plant':
        await _applyPlantEvent(operation, payload);
      case 'species':
        await _applySpeciesEvent(operation, payload);
      case 'entry':
        await _applyEntryEvent(operation, payload);
      case 'location':
        await _applyLocationEvent(operation, payload);
      case 'soil':
        await _applySoilEvent(operation, payload);
    }
  }

  Future<void> _applyPlantEvent(String op, Map<String, dynamic> p) async {
    if (op == 'delete') {
      await _db.plantsDao.deleteById(p['id'] as String);
      return;
    }
    if (op == 'irrigate') {
      final raw = p['lastIrrigatedAt'];
      final when = raw != null ? DateTime.parse(raw as String) : null;
      await _db.plantsDao.updateLastIrrigated(p['id'] as String, when);
      return;
    }
    await _db.plantsDao.upsert(PlantsTableCompanion.insert(
      id: p['id'] as String,
      speciesId: p['speciesId'] as String,
      nickname: p['nickname'] as String,
      soilType: (p['soilId'] ?? p['soilType']) as String,
      irrigationFrequencyDays:
          Value(p['irrigationFrequencyDays'] as int?),
      acquisitionDate: DateTime.parse(p['acquisitionDate'] as String),
      location: Value(p['location'] as String?),
      locationId: Value(p['locationId'] as String?),
      lastIrrigatedAt: Value(p['lastIrrigatedAt'] != null
          ? DateTime.parse(p['lastIrrigatedAt'] as String)
          : null),
      createdAt: DateTime.parse(p['createdAt'] as String),
      syncStatus: const Value(SyncStatus.synced),
    ));
  }

  Future<void> _applySpeciesEvent(String op, Map<String, dynamic> p) async {
    if (op == 'delete') {
      await _db.speciesDao.deleteById(p['id'] as String);
      return;
    }
    final soilIds =
        (p['recommendedSoilIds'] as List<dynamic>?)?.cast<String>() ?? [];
    await _db.speciesDao.upsert(SpeciesTableCompanion.insert(
      id: p['id'] as String,
      scientificName: p['scientificName'] as String,
      popularName: p['popularName'] as String,
      defaultIrrigationFrequencyDays:
          Value(p['defaultIrrigationFrequencyDays'] as int?),
      recommendedSoilTypes: soilIds,
      syncStatus: const Value(SyncStatus.synced),
      createdAt: DateTime.parse(p['createdAt'] as String),
    ));
  }

  Future<void> _applyEntryEvent(String op, Map<String, dynamic> p) async {
    if (op == 'delete') {
      final existing = await _db.entriesDao.getById(p['id'] as String);
      if (existing?.photoPath != null) {
        await _photoStorage.deletePhoto(existing!.photoPath!);
      }
      await _db.entriesDao.deleteById(p['id'] as String);
      return;
    }
    final plantId = p['plantId'] as String;
    final type = EntryType.values.byName(p['type'] as String);

    String? localPhotoPath;
    final photoKey = p['photoKey'] as String?;
    if (photoKey != null) {
      localPhotoPath = await _downloadPhoto(photoKey);
    }

    // Usa Value.absent() quando não há foto no evento ou o download falhou,
    // preservando o photoPath já existente no DB em caso de UPDATE.
    final photoPathValue = localPhotoPath != null
        ? Value<String?>(localPhotoPath)
        : const Value<String?>.absent();

    await _db.entriesDao.upsert(EntriesTableCompanion.insert(
      id: p['id'] as String,
      plantId: plantId,
      date: DateTime.parse(p['date'] as String),
      photoPath: photoPathValue,
      note: Value(p['note'] as String?),
      type: type,
      createdAt: DateTime.parse(p['createdAt'] as String),
      syncStatus: const Value(SyncStatus.synced),
    ));

    // If this is an irrigation, we MUST update the plant's lastIrrigatedAt
    if (type == EntryType.irrigation) {
      final lastDate = await _db.entriesDao.getLastIrrigationDate(plantId);
      await _db.plantsDao.updateLastIrrigated(plantId, lastDate);
    }
  }

  Future<void> _applyLocationEvent(String op, Map<String, dynamic> p) async {
    if (op == 'delete') {
      await _db.locationsDao.deleteById(p['id'] as String);
      return;
    }
    await _db.locationsDao.upsert(LocationsTableCompanion.insert(
      id: p['id'] as String,
      name: p['name'] as String,
      description: Value(p['description'] as String?),
      latitude: Value((p['latitude'] as num?)?.toDouble()),
      longitude: Value((p['longitude'] as num?)?.toDouble()),
      createdAt: DateTime.parse(p['createdAt'] as String),
      syncStatus: const Value(SyncStatus.synced),
    ));
  }

  Future<void> _applySoilEvent(String op, Map<String, dynamic> p) async {
    if (op == 'delete') {
      await _db.soilsDao.deleteSoil(p['id'] as String);
      return;
    }
    await _db.soilsDao.insertSoil(SoilsTableCompanion.insert(
      id: p['id'] as String,
      name: p['name'] as String,
      composition: Value(p['composition'] as String?),
      imagePath: Value(p['imagePath'] as String?),
      imageSource: Value(p['imageSource'] as String?),
      createdAt: DateTime.parse(p['createdAt'] as String),
      syncStatus: const Value(SyncStatus.synced),
    ));
  }
}