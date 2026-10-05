import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
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

const _server = 'https://example.test';
const _otherDevice = 'other-device';

final _allTypes = {for (final t in EntryType.values) t.name};

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

/// Minimal stand-in for Polypodium_server's pull: rev order, the entry-type
/// filter (legacy set without the header) and the `entities` restriction,
/// both applied before paging.
class _FakeServer {
  _FakeServer(this.rows);

  final List<SyncChange> rows;
  bool honorsEntities = true;
  final failingPhotos = <String>{};
  final pulls = <Uri>[];
  final declaredTypes = <Set<String>>[];

  Future<http.Response> handle(http.Request request) async {
    final path = request.url.path;
    if (path == '/api/v1/sync/changes') return _changes(request);
    if (path == '/api/v1/sync/receive') {
      return http.Response(jsonEncode({'appliedCount': 0}), 200);
    }
    if (path == '/api/v1/sync/ack') {
      return http.Response(jsonEncode({'ok': true}), 200);
    }
    if (path.startsWith('/api/v1/photos/')) {
      final key = path.split('/').last;
      return failingPhotos.contains(key)
          ? http.Response('', 500)
          : http.Response.bytes([1, 2, 3], 200);
    }
    return http.Response('', 404);
  }

  http.Response _changes(http.Request request) {
    pulls.add(request.url);
    final params = request.url.queryParameters;
    final since = int.parse(params['since']!);
    final limit = int.parse(params['limit']!);
    final header = request.headers[entryTypesHeader];
    final types = header == null ? legacyEntryTypes : header.split(',').toSet();
    declaredTypes.add(types);
    final entities =
        honorsEntities ? params['entities']?.split(',').toSet() : null;

    final visible = rows
        .where((c) =>
            c.rev > since &&
            (entities == null || entities.contains(c.entityType)) &&
            (c.entityType != 'entry' || types.contains(c.payload['type'])))
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

  List<Uri> get backfillPulls =>
      pulls.where((u) => u.queryParameters['entities'] == 'entry').toList();
}

SyncChange _entry(String id, String type, int rev, {String? photoKey}) =>
    SyncChange(
      entityType: 'entry',
      entityId: id,
      payload: {
        'id': id,
        'plantId': 'plant1',
        'type': type,
        'date': '2026-01-01T00:00:00.000',
        'createdAt': '2026-01-01T00:00:00.000',
        if (photoKey != null) 'photoKey': photoKey,
      },
      updatedAt: DateTime.utc(2026, 1, 1),
      deviceId: _otherDevice,
      rev: rev,
    );

void main() {
  late AppDatabase db;
  late DriftSyncCursorStore cursors;
  late SyncOrchestrator orchestrator;
  late _FakeServer server;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    cursors = DriftSyncCursorStore(db);
    orchestrator = SyncOrchestrator(
      storage: DriftSyncStorageAdapter(db),
      cursors: cursors,
      httpClient: const SyncHttpClient(),
      photos: PhotoSyncClient(_FakePhotoStorage()),
    );
    final now = DateTime(2026, 1, 1);
    await db.speciesDao.upsert(SpeciesTableCompanion.insert(
      id: 'species1',
      scientificName: 'Sci',
      popularName: 'Pop',
      recommendedSoilTypes: const [],
      createdAt: now,
      updatedAt: now,
    ));
    await db.plantsDao.upsert(PlantsTableCompanion.insert(
      id: 'plant1',
      speciesId: 'species1',
      nickname: 'Samambaia',
      soilType: 'loamy',
      acquisitionDate: now,
      createdAt: now,
      updatedAt: now,
    ));

    // A legacy client pulled up to rev 3 and never saw r1; r2 lies past
    // its cursor.
    server = _FakeServer([
      _entry('e1', 'observation', 1),
      _entry('r1', 'repotting', 2, photoKey: 'r1.jpg'),
      _entry('e2', 'observation', 3),
      _entry('r2', 'repotting', 4),
    ]);
  });

  tearDown(() async => db.close());

  Future<SyncResult> sync() => http.runWithClient(
        () => orchestrator.sync(
            serverUrl: _server, token: 't', deviceId: 'this-device'),
        () => MockClient(server.handle),
      );

  Future<int> backfillCursor(Set<String> types) =>
      cursors.getBackfillCursor(syncServerPeerId, types);

  test(
      'a device that already pulled is assumed to have declared the legacy '
      'set and backfills the hidden entries behind its cursor', () async {
    await cursors.setPullCursor(syncServerPeerId, 3);

    final result = await sync();

    final newTypes = _allTypes.difference(legacyEntryTypes);
    expect(newTypes, contains('repotting'));
    final backfills = server.backfillPulls;
    expect(backfills, hasLength(1));
    expect(backfills.single.queryParameters['since'], '0');
    expect(backfills.single.queryParameters['entities'], 'entry');
    expect(server.declaredTypes[server.pulls.indexOf(backfills.single)],
        newTypes);

    final r1 = await db.entriesDao.getById('r1');
    expect(r1!.type, EntryType.repotting);
    expect(r1.photoPath, '/local/r1.jpg');
    expect(await db.entriesDao.getById('r2'), isNotNull);
    expect(result.pulled, 1 + 2);

    // The main pull moved on from its own cursor; the backfill didn't touch
    // it, and leaves no cursor of its own behind.
    expect(server.pulls.first.queryParameters['since'], '3');
    expect(await cursors.getPullCursor(syncServerPeerId), 4);
    expect(await backfillCursor(newTypes), 0);
    expect(await cursors.getDeclaredEntryTypes(syncServerPeerId),
        containsAll(_allTypes));

    await sync();
    expect(server.backfillPulls, hasLength(1));
  });

  test('a fresh device declares everything it knows and backfills nothing',
      () async {
    await sync();

    expect(server.backfillPulls, isEmpty);
    expect(await db.entriesDao.getById('r1'), isNotNull);
    expect(await cursors.getDeclaredEntryTypes(syncServerPeerId), _allTypes);
  });

  test('nothing new to declare means no backfill', () async {
    await cursors.setPullCursor(syncServerPeerId, 3);
    await cursors.addDeclaredEntryTypes(syncServerPeerId, _allTypes);

    await sync();

    expect(server.backfillPulls, isEmpty);
    expect(await db.entriesDao.getById('r1'), isNull);
  });

  test('an interrupted backfill resumes from its own cursor', () async {
    await cursors.setPullCursor(syncServerPeerId, 3);
    final newTypes = _allTypes.difference(legacyEntryTypes);
    server.rows.add(_entry('r3', 'repotting', 5, photoKey: 'r3.jpg'));
    server.failingPhotos.add('r3.jpg');

    await sync();

    // r1 and r2 applied, r3's photo failed: still undeclared.
    expect(await db.entriesDao.getById('r1'), isNotNull);
    expect(await db.entriesDao.getById('r3'), isNull);
    expect(await backfillCursor(newTypes), 4);
    expect(await cursors.getPullCursor(syncServerPeerId), 4);
    expect(await cursors.getDeclaredEntryTypes(syncServerPeerId),
        legacyEntryTypes);

    server.failingPhotos.clear();
    await sync();

    expect(server.backfillPulls.last.queryParameters['since'], '4');
    expect((await db.entriesDao.getById('r3'))!.photoPath, '/local/r3.jpg');
    expect(await backfillCursor(newTypes), 0);
    expect(await cursors.getDeclaredEntryTypes(syncServerPeerId),
        containsAll(_allTypes));
  });

  test('a server ignoring the restriction gets no backfill, once', () async {
    await cursors.setPullCursor(syncServerPeerId, 3);
    server.honorsEntities = false;

    final result = await sync();

    expect(server.backfillPulls, hasLength(1));
    expect(await db.entriesDao.getById('r1'), isNull);
    expect(result.pulled, 1);
    expect(await cursors.getDeclaredEntryTypes(syncServerPeerId),
        containsAll(_allTypes));

    await sync();
    expect(server.backfillPulls, hasLength(1));
  });
}
