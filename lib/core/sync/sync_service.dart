import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../../features/workspaces/data/workspace_auth_client.dart';
import '../database/app_database.dart';
import '../enums.dart';
import '../storage/photo_storage.dart';
import 'workspace_config_store.dart';

class SyncResult {
  final int pulled;
  final int pushed;
  const SyncResult({required this.pulled, required this.pushed});
}

class SyncService {
  SyncService(
    this._db,
    this._store,
    this._photoStorage, {
    WorkspaceAuthClient authClient = const WorkspaceAuthClient(),
  }) : _authClient = authClient;

  final AppDatabase _db;
  final WorkspaceConfigStore _store;
  final PhotoStorage _photoStorage;
  final WorkspaceAuthClient _authClient;

  String? get token => _store.current.token;
  String? get deviceId => _store.current.deviceId;
  String? get serverUrl => _store.current.serverUrl;
  int get cursor => _store.current.cursor;
  String? get userEmail => _store.current.userEmail;
  bool get isLoggedIn => _store.current.isLoggedIn;
  DateTime? get lastSyncAt => _store.current.lastSyncAt;

  Map<String, String> get _authHeaders => {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

  Future<void> checkServer(String serverUrl) =>
      _authClient.checkServer(serverUrl);

  Future<void> login(String serverUrl, String email, String password) async {
    final id = deviceId ?? const Uuid().v4();
    final result = await _authClient.login(
      serverUrl: serverUrl,
      email: email,
      password: password,
      deviceId: id,
    );
    await _store.save(_store.current.copyWith(
      token: result.token,
      deviceId: result.deviceId,
      serverUrl: serverUrl,
      userEmail: email,
    ));
  }

  Future<void> logout() async {
    await _store.save(_store.current.disconnected());
  }

  Future<SyncResult> sync() async {
    if (!isLoggedIn) throw Exception('Não autenticado');
    final pulled = await _pull();
    final pushed = await _push();
    await _store.save(_store.current.copyWith(lastSyncAt: DateTime.now()));
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
        await _store.save(_store.current.copyWith(cursor: nextCursor));
        since = nextCursor;
      }

      if (!hasMore) break;
    }

    return totalPulled;
  }

  Future<int> _push() async {
    await _enqueuePending();
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

  /// Enqueues any entities with syncStatus=pending that are not yet in the
  /// sync_queue. This covers data created before the enqueue call was wired
  /// up in each repository's save(). Dependency order is intentional:
  /// species/soils/locations must be pushed before plants, plants before entries.
  Future<void> _enqueuePending() async {
    final queuedIds = await _db.syncQueueDao.getPendingEntityIds();

    for (final row in await _db.speciesDao.getAll()) {
      if (row.syncStatus == SyncStatus.pending && !queuedIds.contains(row.id)) {
        await _db.syncQueueDao.enqueue(
          entityType: 'species',
          entityId: row.id,
          operation: 'create',
          payload: jsonEncode({
            'id': row.id,
            'scientificName': row.scientificName,
            'popularName': row.popularName,
            'defaultIrrigationFrequencyDays': row.defaultIrrigationFrequencyDays,
            'recommendedSoilIds': row.recommendedSoilTypes,
            'syncStatus': row.syncStatus.name,
            'createdAt': row.createdAt.toIso8601String(),
          }),
          createdAt: row.createdAt,
        );
      }
    }

    for (final row in await _db.soilsDao.getAllSoils()) {
      if (row.syncStatus == SyncStatus.pending && !queuedIds.contains(row.id)) {
        await _db.syncQueueDao.enqueue(
          entityType: 'soil',
          entityId: row.id,
          operation: 'create',
          payload: jsonEncode({
            'id': row.id,
            'name': row.name,
            'composition': row.composition,
            'imagePath': row.imagePath,
            'imageSource': row.imageSource,
            'createdAt': row.createdAt.toIso8601String(),
            'syncStatus': row.syncStatus.name,
          }),
          createdAt: row.createdAt,
        );
      }
    }

    for (final row in await _db.locationsDao.getAll()) {
      if (row.syncStatus == SyncStatus.pending && !queuedIds.contains(row.id)) {
        await _db.syncQueueDao.enqueue(
          entityType: 'location',
          entityId: row.id,
          operation: 'create',
          payload: jsonEncode({
            'id': row.id,
            'name': row.name,
            'description': row.description,
            'latitude': row.latitude,
            'longitude': row.longitude,
            'createdAt': row.createdAt.toIso8601String(),
            'syncStatus': row.syncStatus.name,
          }),
          createdAt: row.createdAt,
        );
      }
    }

    for (final row in await _db.plantsDao.getAll()) {
      if (row.syncStatus == SyncStatus.pending && !queuedIds.contains(row.id)) {
        await _db.syncQueueDao.enqueue(
          entityType: 'plant',
          entityId: row.id,
          operation: 'create',
          payload: jsonEncode({
            'id': row.id,
            'speciesId': row.speciesId,
            'nickname': row.nickname,
            'soilId': row.soilType,
            'irrigationFrequencyDays': row.irrigationFrequencyDays,
            'acquisitionDate': row.acquisitionDate.toIso8601String(),
            'location': row.location,
            'locationId': row.locationId,
            'lastIrrigatedAt': row.lastIrrigatedAt?.toIso8601String(),
            'createdAt': row.createdAt.toIso8601String(),
            'syncStatus': row.syncStatus.name,
          }),
          createdAt: row.createdAt,
        );
      }
    }

    for (final row in await _db.entriesDao.getAll()) {
      if (row.syncStatus == SyncStatus.pending && !queuedIds.contains(row.id)) {
        await _db.syncQueueDao.enqueue(
          entityType: 'entry',
          entityId: row.id,
          operation: 'create',
          payload: jsonEncode({
            'id': row.id,
            'plantId': row.plantId,
            'date': row.date.toIso8601String(),
            'photoPath': row.photoPath,
            'note': row.note,
            'type': row.type.name,
            'numericValue': row.numericValue,
            'extraData': row.extraData,
            'createdAt': row.createdAt.toIso8601String(),
            'syncStatus': row.syncStatus.name,
          }),
          createdAt: row.createdAt,
        );
      }
    }
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
      numericValue: Value((p['numericValue'] as num?)?.toDouble()),
      extraData: Value(p['extraData'] as String?),
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