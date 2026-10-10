import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:path/path.dart' as p;
import 'package:polypodium_core/polypodium_core.dart';

import 'package:polypodium/core/database/app_database.dart';
import 'package:polypodium/core/database/sync_cursors_dao.dart';
import 'package:polypodium/core/enums.dart';
import 'package:polypodium/core/storage/photo_storage.dart';
import 'package:polypodium/core/sync/drift_sync_cursor_store.dart';
import 'package:polypodium/core/sync/drift_sync_storage_adapter.dart';
import 'package:polypodium/core/sync/photo_sync_client.dart';
import 'package:polypodium/core/sync/sync_http_client.dart';
import 'package:polypodium/core/sync/sync_orchestrator.dart';
import 'package:polypodium/features/entries/data/entries_repository.dart';
import 'package:polypodium/features/entries/domain/entry_model.dart';

const _server = 'https://example.test';

class _FakePhotoStorage implements PhotoStorage {
  @override
  String get baseDirName => 'test_photos';

  @override
  Future<void> cleanOrphanPhotos(List<String> referencedPaths) async {}

  @override
  Future<void> deletePhoto(String path) async {}

  @override
  Future<String> savePhoto(dynamic file) async => '';

  @override
  Future<String> savePhotoBytes(List<int> bytes, String fileName) async =>
      '/local/$fileName';

  @override
  Future<String> restorePhoto(List<int> bytes, String fileName) async => '';
}

/// Pull/push/photo endpoints of Polypodium_server, enough for photos: the
/// `entities` restriction (echoing only the entity types it stores) and the
/// photo files by key.
class _FakeServer {
  final rows = <SyncChange>[];
  final pushed = <SyncChange>[];
  final uploads = <String, List<int>>{};
  final downloads = <String>[];
  final pulls = <Uri>[];
  // Every server stored `bed` (pots) from its first per-entity tables.
  Set<String> knownEntities = {...legacyEntityTypes, 'bed', 'entry_photo'};

  Future<http.Response> handle(http.Request request) async {
    final path = request.url.path;
    if (path == '/api/v1/sync/changes') return _changes(request);
    if (path == '/api/v1/sync/receive') {
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      for (final c in body['changes'] as List<dynamic>) {
        pushed.add(SyncChange.fromJson(c as Map<String, dynamic>));
      }
      return http.Response(jsonEncode({'appliedCount': 0}), 200);
    }
    if (path == '/api/v1/sync/ack') {
      return http.Response(jsonEncode({'ok': true}), 200);
    }
    if (path.startsWith('/api/v1/photos/')) {
      final key = path.split('/').last;
      if (request.method == 'PUT') {
        uploads[key] = request.bodyBytes;
        return http.Response(jsonEncode({'ok': true, 'photoKey': key}), 200);
      }
      downloads.add(key);
      return http.Response.bytes([1, 2, 3], 200);
    }
    return http.Response('', 404);
  }

  http.Response _changes(http.Request request) {
    pulls.add(request.url);
    final params = request.url.queryParameters;
    final since = int.parse(params['since']!);
    final limit = int.parse(params['limit']!);
    final requested = params['entities']?.split(',').toSet();
    final entities = requested?.intersection(knownEntities);
    final visible = rows
        .where((c) =>
            c.rev > since &&
            knownEntities.contains(c.entityType) &&
            (entities == null || entities.contains(c.entityType)))
        .toList()
      ..sort((a, b) => a.rev.compareTo(b.rev));
    final page = visible.take(limit).toList();
    return http.Response(
      jsonEncode({
        'changes': page.map((c) => c.toJson()).toList(),
        'nextCursor': page.isEmpty ? since : page.last.rev,
        'hasMore': visible.length > limit,
        if (entities != null) 'entities': entities.toList()..sort(),
      }),
      200,
    );
  }

  List<Uri> get photoBackfills => pulls
      .where((u) =>
          u.queryParameters['entities']?.split(',').contains('entry_photo') ??
          false)
      .toList();
}

SyncChange _remoteEntry(String id, int rev, {String? photoKey}) => SyncChange(
      entityType: 'entry',
      entityId: id,
      payload: {
        'id': id,
        'plantId': 'plant1',
        'type': 'observation',
        'date': '2026-01-01T00:00:00.000',
        'createdAt': '2026-01-01T00:00:00.000',
        if (photoKey != null) 'photoKey': photoKey,
      },
      updatedAt: DateTime.utc(2026, 1, 1),
      deviceId: 'other-device',
      rev: rev,
    );

SyncChange _remotePhoto(String id, String entryId, int position, int rev,
        {DateTime? deletedAt}) =>
    SyncChange(
      entityType: 'entry_photo',
      entityId: id,
      payload: {
        'id': id,
        'entryId': entryId,
        'position': position,
        'createdAt': '2026-01-01T00:00:00.000',
        if (deletedAt == null) 'photoKey': '$id.jpg' else 'photoPath': '/x',
      },
      updatedAt: deletedAt ?? DateTime.utc(2026, 1, 1),
      deletedAt: deletedAt,
      deviceId: 'other-device',
      rev: rev,
    );

void main() {
  late AppDatabase db;
  late DriftSyncCursorStore cursors;
  late SyncOrchestrator orchestrator;
  late _FakeServer server;
  late EntriesRepository entries;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory(), deviceId: 'this');
    cursors = DriftSyncCursorStore(db);
    orchestrator = SyncOrchestrator(
      storage: DriftSyncStorageAdapter(db),
      cursors: cursors,
      httpClient: const SyncHttpClient(),
      photos: PhotoSyncClient(_FakePhotoStorage()),
    );
    entries = EntriesRepository(db, _FakePhotoStorage());
    server = _FakeServer();
    final now = DateTime(2026, 1, 1);
    await db.plantsDao.upsert(PlantsTableCompanion.insert(
      id: 'plant1',
      speciesId: 'species1',
      nickname: 'Samambaia',
      soilType: 'loamy',
      acquisitionDate: now,
      createdAt: now,
      updatedAt: now,
    ));
  });

  tearDown(() async => db.close());

  Future<SyncResult> sync() => http.runWithClient(
        () => orchestrator.sync(
            serverUrl: _server, token: 't', deviceId: 'this-device'),
        () => MockClient(server.handle),
      );

  test('every photo of an entry is uploaded by key and pushed', () async {
    final dir = await Directory.systemTemp.createTemp();
    addTearDown(() => dir.delete(recursive: true));
    Future<String> file(String name, int byte) async {
      final f = File(p.join(dir.path, name));
      await f.writeAsBytes([byte]);
      return f.path;
    }

    await entries.create(EntryModel(
      id: 'e1',
      plantId: 'plant1',
      date: DateTime(2026, 2, 1),
      type: EntryType.observation,
      photoPath: await file('a.jpg', 1),
      extraPhotos: [
        EntryPhoto(id: 'ph2', path: await file('b.png', 2)),
        EntryPhoto(id: 'ph3', path: await file('c.jpg', 3)),
      ],
      createdAt: DateTime(2026, 2, 1),
    ));

    await sync();

    expect(server.uploads, {
      'e1.jpg': [1],
      'ph2.png': [2],
      'ph3.jpg': [3],
    });
    // The entry goes first, its photos after it.
    expect(server.pushed.map((c) => (c.entityType, c.entityId)), [
      ('entry', 'e1'),
      ('entry_photo', 'ph2'),
      ('entry_photo', 'ph3'),
    ]);
    final ph2 = server.pushed[1].payload;
    expect(ph2['photoKey'], 'ph2.png');
    expect(ph2.containsKey('photoPath'), isFalse);
    expect(ph2['entryId'], 'e1');
    expect(ph2['position'], 1);
    expect(server.pushed[2].payload['position'], 2);
  });

  test('pulled photos are downloaded and read back in order', () async {
    server.rows.addAll([
      _remoteEntry('e1', 1, photoKey: 'e1.jpg'),
      _remotePhoto('ph3', 'e1', 2, 2),
      _remotePhoto('ph2', 'e1', 1, 3),
    ]);

    await sync();

    expect(server.downloads, ['e1.jpg', 'ph3.jpg', 'ph2.jpg']);
    final entry = await entries.getById('e1');
    expect(entry!.photos.map((p) => (p.id, p.path)), [
      ('e1', '/local/e1.jpg'),
      ('ph2', '/local/ph2.jpg'),
      ('ph3', '/local/ph3.jpg'),
    ]);

    // A deleted photo drops out, keeping its local path.
    server.rows.add(
        _remotePhoto('ph2', 'e1', 1, 4, deletedAt: DateTime.utc(2026, 3, 1)));
    await sync();
    expect(
        (await entries.getById('e1'))!.photos.map((p) => p.id), ['e1', 'ph3']);
    expect(
        (await db.entryPhotosDao.getById('ph2'))!.photoPath, '/local/ph2.jpg');
  });

  group('entity backfill', () {
    setUp(() {
      // A release that ignored entry photos pulled up to rev 3.
      server.rows.addAll([
        _remoteEntry('e1', 1, photoKey: 'e1.jpg'),
        _remotePhoto('ph2', 'e1', 1, 2),
        _remoteEntry('e2', 3),
        _remotePhoto('ph9', 'e1', 2, 4),
      ]);
    });

    test('a device that already pulled fetches the entry photos it skipped',
        () async {
      await cursors.setPullCursor(syncServerPeerId, 3);
      // Entry types are a backfill of their own.
      await cursors.addDeclaredEntryTypes(
          syncServerPeerId, {for (final t in EntryType.values) t.name});
      await db.entriesDao.upsert(EntriesTableCompanion.insert(
        id: 'e1',
        plantId: 'plant1',
        date: DateTime(2026, 1, 1),
        photoPath: const Value('/local/e1.jpg'),
        type: EntryType.observation,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime.utc(2026, 1, 1),
        deviceId: const Value('other-device'),
      ));

      final result = await sync();

      expect(server.photoBackfills, hasLength(1));
      expect(server.photoBackfills.single.queryParameters['since'], '0');
      expect((await entries.getById('e1'))!.photos.map((p) => p.id),
          ['e1', 'ph2', 'ph9']);
      // ph9 by the regular pull, ph2 (and ph9 again) by the backfill.
      expect(result.pulled, 1 + 2);
      expect(await cursors.getDeclaredEntityTypes(syncServerPeerId),
          contains('entry_photo'));
      expect(
          await cursors
              .getEntityBackfillCursor(
                  syncServerPeerId, {'bed', 'entry_photo'}),
          0);

      await sync();
      expect(server.photoBackfills, hasLength(1));
    });

    test('a fresh device has nothing to backfill', () async {
      await sync();

      expect(server.photoBackfills, isEmpty);
      expect((await entries.getById('e1'))!.photos.map((p) => p.id),
          ['e1', 'ph2', 'ph9']);
    });

    test('a server without entry photos leaves them undeclared', () async {
      await cursors.setPullCursor(syncServerPeerId, 3);
      server.knownEntities = {...legacyEntityTypes, 'bed'};

      await sync();
      await sync();

      expect(server.photoBackfills, hasLength(2));
      expect(await cursors.getDeclaredEntityTypes(syncServerPeerId),
          isNot(contains('entry_photo')));

      // Once the server is updated, the next sync recovers them.
      server.knownEntities.add('entry_photo');
      await sync();
      expect(await db.entryPhotosDao.getById('ph2'), isNotNull);
      expect(await cursors.getDeclaredEntityTypes(syncServerPeerId),
          contains('entry_photo'));
    });
  });

  test('a device that pulled before pots existed backfills them, once',
      () async {
    // A release that ignored `bed` pulled past this pot.
    server.rows.add(SyncChange(
      entityType: 'bed',
      entityId: 'pot1',
      payload: const {
        'id': 'pot1',
        'name': 'Vaso azul',
        'kind': 'pot',
        'createdAt': '2026-01-01T00:00:00.000',
      },
      updatedAt: DateTime.utc(2026, 1, 1),
      deviceId: 'other-device',
      rev: 1,
    ));
    await cursors.setPullCursor(syncServerPeerId, 1);
    await cursors.addDeclaredEntryTypes(
        syncServerPeerId, {for (final t in EntryType.values) t.name});
    await cursors.addDeclaredEntityTypes(
        syncServerPeerId, {...legacyEntityTypes, 'entry_photo'});

    await sync();

    expect((await db.potsDao.getById('pot1'))!.name, 'Vaso azul');
    expect(await cursors.getDeclaredEntityTypes(syncServerPeerId),
        contains('bed'));
    final backfills = server.pulls
        .where((u) => u.queryParameters['entities'] == 'bed')
        .toList();
    expect(backfills, hasLength(1));
    expect(backfills.single.queryParameters['since'], '0');

    await sync();
    expect(
        server.pulls.where((u) => u.queryParameters['entities'] == 'bed'),
        hasLength(1));
  });

  test('an unknown entity type is ignored on pull', () async {
    await DriftSyncStorageAdapter(db).applyRemoteChange(SyncChange(
      entityType: 'future_thing',
      entityId: 'x',
      payload: const {'id': 'x'},
      updatedAt: DateTime.utc(2026, 1, 1),
      deviceId: 'other-device',
      rev: 1,
    ));
  });
}
