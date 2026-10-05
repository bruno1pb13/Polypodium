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

/// Push side of Polypodium_server: stores the changes of the entity types
/// it knows and drops the rest, reporting them (and the types it stores)
/// unless it predates that; photo files by key, HEAD included.
class _FakeServer {
  _FakeServer(this.stored);

  Set<String> stored;
  bool reports = true;
  final rows = <String, SyncChange>{};
  final pushed = <SyncChange>[];
  final files = <String>{};
  final uploads = <String>[];
  final heads = <String>[];
  final failingUploads = <String>{};

  void clearLog() {
    pushed.clear();
    uploads.clear();
    heads.clear();
  }

  Future<http.Response> handle(http.Request request) async {
    final path = request.url.path;
    if (path == '/api/v1/sync/changes') {
      final requested = request.url.queryParameters['entities'];
      return _json({
        'changes': [],
        'nextCursor': int.parse(request.url.queryParameters['since']!),
        'hasMore': false,
        if (requested != null)
          'entities':
              requested.split(',').toSet().intersection(stored).toList(),
        if (reports) 'supportedEntities': stored.toList()..sort(),
      });
    }
    if (path == '/api/v1/sync/receive') {
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      final ignored = <String>{};
      for (final json in body['changes'] as List<dynamic>) {
        final change = SyncChange.fromJson(json as Map<String, dynamic>);
        pushed.add(change);
        if (stored.contains(change.entityType)) {
          rows[change.entityId] = change;
        } else {
          ignored.add(change.entityType);
        }
      }
      return _json({
        'appliedCount': 0,
        if (reports) 'ignoredEntityTypes': ignored.toList(),
      });
    }
    if (path == '/api/v1/sync/ack') return _json({'ok': true});
    if (path.startsWith('/api/v1/photos/')) {
      final key = path.split('/').last;
      switch (request.method) {
        case 'HEAD':
          heads.add(key);
          return http.Response('', files.contains(key) ? 200 : 404);
        case 'PUT':
          if (failingUploads.contains(key)) return http.Response('', 500);
          uploads.add(key);
          files.add(key);
          return _json({'ok': true, 'photoKey': key});
      }
      return http.Response.bytes([1, 2, 3], 200);
    }
    return http.Response('', 404);
  }

  http.Response _json(Object body) => http.Response(jsonEncode(body), 200);

  List<(String, String)> get pushedIds =>
      [for (final c in pushed) (c.entityType, c.entityId)];
}

void main() {
  late AppDatabase db;
  late DriftSyncCursorStore cursors;
  late SyncOrchestrator orchestrator;
  late _FakeServer server;
  late Directory dir;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory(), deviceId: 'this');
    cursors = DriftSyncCursorStore(db);
    orchestrator = SyncOrchestrator(
      storage: DriftSyncStorageAdapter(db),
      cursors: cursors,
      httpClient: const SyncHttpClient(),
      photos: PhotoSyncClient(_FakePhotoStorage()),
    );
    dir = await Directory.systemTemp.createTemp();
    Future<String> file(String name) async {
      final f = File(p.join(dir.path, name));
      await f.writeAsBytes([1]);
      return f.path;
    }

    final now = DateTime(2026, 1, 1);
    await db.plantsDao.upsert(PlantsTableCompanion.insert(
      id: 'plant1',
      speciesId: 'species1',
      nickname: 'Samambaia',
      soilType: 'loamy',
      acquisitionDate: now,
      createdAt: now,
      updatedAt: now,
      localRev: Value(await db.syncMetaDao.nextRev()),
    ));
    await db.into(db.defensivosTable).insert(DefensivosTableCompanion.insert(
          id: 'd1',
          name: 'Calda bordalesa',
          createdAt: now,
          updatedAt: now,
          localRev: Value(await db.syncMetaDao.nextRev()),
        ));
    await EntriesRepository(db, _FakePhotoStorage()).create(EntryModel(
      id: 'e1',
      plantId: 'plant1',
      date: DateTime(2026, 2, 1),
      type: EntryType.observation,
      photoPath: await file('a.jpg'),
      extraPhotos: [
        EntryPhoto(id: 'ph2', path: await file('b.png')),
        EntryPhoto(id: 'ph3', path: await file('c.jpg')),
      ],
      createdAt: DateTime(2026, 2, 1),
    ));
  });

  tearDown(() async {
    await db.close();
    await dir.delete(recursive: true);
  });

  Future<SyncResult> sync() => http.runWithClient(
        () => orchestrator.sync(
            serverUrl: _server, token: 't', deviceId: 'this-device'),
        () => MockClient(server.handle),
      );

  Future<Set<String>> confirmed() =>
      cursors.getConfirmedEntityTypes(syncServerPeerId);

  test(
      'rows of a type the server dropped are re-pushed once it stores it, '
      'uploading only the photos it lacks', () async {
    server =
        _FakeServer({...originalServerEntityTypes, 'defensivo', 'reminder'});

    await sync();

    // Photos go up before their rows, which the server then drops.
    expect(server.uploads, ['e1.jpg', 'ph2.png', 'ph3.jpg']);
    expect(server.pushedIds,
        containsAll([('entry_photo', 'ph2'), ('entry_photo', 'ph3')]));
    expect(server.rows.keys, isNot(contains('ph2')));
    // A device that never pushed sends every row anyway: whatever the
    // server stores is confirmed right away.
    expect(await confirmed(),
        DriftSyncStorageAdapter(db).entityTypes.difference({'entry_photo'}));

    server.files.remove('ph3.jpg');
    server.stored.add('entry_photo');
    server.clearLog();
    final result = await sync();

    expect(server.pushedIds, [('entry_photo', 'ph2'), ('entry_photo', 'ph3')]);
    expect(result.pushed, 2);
    expect(server.heads, ['ph2.png', 'ph3.jpg']);
    expect(server.uploads, ['ph3.jpg']);
    final ph2 = server.rows['ph2']!;
    expect(ph2.payload['photoKey'], 'ph2.png');
    expect(ph2.payload.containsKey('photoPath'), isFalse);
    expect(ph2.payload['entryId'], 'e1');
    expect(ph2.deviceId, 'this-device');
    expect(await confirmed(), contains('entry_photo'));
    expect(await cursors.getRepushCursor(syncServerPeerId, 'entry_photo'), 0);

    server.clearLog();
    await sync();
    expect(server.pushed, isEmpty);
    expect(server.heads, isEmpty);
  });

  test(
      'a server that never reported its types is left alone, and reconciled '
      'once updated: only the types newer than the original ones go again',
      () async {
    server = _FakeServer({...originalServerEntityTypes})..reports = false;

    await sync();
    expect(server.pushed, hasLength(5)); // plant, defensivo, entry, 2 photos
    server.clearLog();
    await sync();
    expect(server.pushed, isEmpty);
    expect(server.heads, isEmpty);
    expect(await confirmed(), isEmpty);

    server
      ..reports = true
      ..stored = {...originalServerEntityTypes, 'entry_photo', 'defensivo'};
    server.clearLog();
    await sync();

    expect(
        server.pushedIds,
        unorderedEquals([
          ('entry_photo', 'ph2'),
          ('entry_photo', 'ph3'),
          ('defensivo', 'd1'),
        ]));
    expect(server.heads, unorderedEquals(['ph2.png', 'ph3.jpg']));
    expect(server.uploads, isEmpty);
    expect(await confirmed(),
        DriftSyncStorageAdapter(db).entityTypes.difference({'reminder'}));

    server.clearLog();
    await sync();
    expect(server.pushed, isEmpty);
  });

  test('an interrupted re-push resumes where it stopped', () async {
    server = _FakeServer({...originalServerEntityTypes});
    await sync();

    server.files.clear();
    server.failingUploads.add('ph3.jpg');
    server.stored.add('entry_photo');
    server.clearLog();
    await sync();

    expect(server.pushedIds, [('entry_photo', 'ph2')]);
    expect(await confirmed(), isNot(contains('entry_photo')));
    expect(await cursors.getRepushCursor(syncServerPeerId, 'entry_photo'),
        server.pushed.single.rev);

    server.failingUploads.clear();
    server.clearLog();
    await sync();

    expect(server.pushedIds, [('entry_photo', 'ph3')]);
    expect(server.uploads, ['ph3.jpg']);
    expect(await confirmed(), contains('entry_photo'));
  });

  test('a type the server stops storing is re-pushed when it comes back',
      () async {
    server =
        _FakeServer({...originalServerEntityTypes, 'defensivo', 'reminder'});
    await sync();
    expect(await confirmed(), contains('defensivo'));

    server.stored.remove('defensivo');
    await sync();
    expect(await confirmed(), isNot(contains('defensivo')));

    server.stored.add('defensivo');
    server.clearLog();
    await sync();
    expect(server.pushedIds, [('defensivo', 'd1')]);
    expect(await confirmed(), contains('defensivo'));
  });
}
