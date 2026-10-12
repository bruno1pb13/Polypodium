import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:polypodium_core/polypodium_core.dart';

import 'package:polypodium/core/database/app_database.dart';
import 'package:polypodium/core/database/sync_cursors_dao.dart';
import 'package:polypodium/core/storage/photo_storage.dart';
import 'package:polypodium/core/sync/drift_sync_cursor_store.dart';
import 'package:polypodium/core/sync/drift_sync_storage_adapter.dart';
import 'package:polypodium/core/sync/photo_sync_client.dart';
import 'package:polypodium/core/sync/sync_http_client.dart';
import 'package:polypodium/core/sync/sync_orchestrator.dart';

const _server = 'https://example.test';
const _otherDevice = 'other-device';
final _when = DateTime.utc(2026, 1, 1);

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

/// Stand-in for Polypodium_server's pull: rev order, the `entities`
/// restriction applied before paging, and `remaining` on `count=1` unless
/// [counts] is off (a server predating it).
class _FakeServer {
  _FakeServer(this.rows);

  final List<SyncChange> rows;
  bool counts = true;
  final pulls = <Uri>[];

  Future<http.Response> handle(http.Request request) async {
    final path = request.url.path;
    if (path == '/api/v1/sync/changes') return _changes(request);
    if (path == '/api/v1/sync/receive') {
      return http.Response(jsonEncode({'appliedCount': 0}), 200);
    }
    if (path == '/api/v1/sync/ack') {
      return http.Response(jsonEncode({'ok': true}), 200);
    }
    return http.Response('', 404);
  }

  http.Response _changes(http.Request request) {
    pulls.add(request.url);
    final params = request.url.queryParameters;
    final since = int.parse(params['since']!);
    final limit = int.parse(params['limit']!);
    final entities = params['entities']?.split(',').toSet();

    final visible = rows
        .where((c) =>
            c.rev > since &&
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
        if (counts && params['count'] == '1') 'remaining': visible.length,
      }),
      200,
    );
  }

  List<Uri> get essentialsPulls => pulls
      .where((u) =>
          u.queryParameters.containsKey('entities') &&
          !u.queryParameters['entities']!.contains('entry'))
      .toList();
}

SyncChange _species(int rev) => SyncChange(
      entityType: 'species',
      entityId: 'species1',
      payload: {
        'scientificName': 'Sci',
        'popularName': 'Pop',
        'createdAt': _when.toIso8601String(),
      },
      updatedAt: _when,
      deviceId: _otherDevice,
      rev: rev,
    );

SyncChange _plant(String id, int rev) => SyncChange(
      entityType: 'plant',
      entityId: id,
      payload: {
        'speciesId': 'species1',
        'nickname': id,
        'soilType': 'loamy',
        'acquisitionDate': _when.toIso8601String(),
        'createdAt': _when.toIso8601String(),
      },
      updatedAt: _when,
      deviceId: _otherDevice,
      rev: rev,
    );

SyncChange _entry(String id, int rev) => SyncChange(
      entityType: 'entry',
      entityId: id,
      payload: {
        'id': id,
        'plantId': 'plant1',
        'type': 'observation',
        'date': _when.toIso8601String(),
        'createdAt': _when.toIso8601String(),
      },
      updatedAt: _when,
      deviceId: _otherDevice,
      rev: rev,
    );

/// A species, then [entries] entries with the plants interleaved among
/// them by rev -- the plants must not wait for the history before them.
List<SyncChange> _garden({required int entries}) {
  var rev = 0;
  return [
    _species(++rev),
    for (var i = 0; i < entries; i++) ...[
      _entry('e$i', ++rev),
      if (i % 100 == 99) _plant('plant${i ~/ 100}', ++rev),
    ],
  ];
}

void main() {
  late AppDatabase db;
  late SyncOrchestrator orchestrator;
  late _FakeServer server;
  late List<SyncProgress?> reports;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    orchestrator = SyncOrchestrator(
      storage: DriftSyncStorageAdapter(db),
      cursors: DriftSyncCursorStore(db),
      httpClient: const SyncHttpClient(),
      photos: PhotoSyncClient(_FakePhotoStorage()),
    );
    reports = [];
  });

  tearDown(() async => db.close());

  Future<SyncResult> sync() => http.runWithClient(
        () => orchestrator.sync(
          serverUrl: _server,
          token: 't',
          deviceId: 'this-device',
          onProgress: reports.add,
        ),
        () => MockClient(server.handle),
      );

  test(
      'a fresh device facing a big garden gets the essentials first, then '
      'the full pull reports its progress as a large one', () async {
    server = _FakeServer(_garden(entries: 400));

    final result = await sync();

    final essentialsPull = server.essentialsPulls.single;
    expect(essentialsPull.queryParameters['since'], '0');
    expect(essentialsPull.queryParameters['entities']!.split(','),
        containsAll(['species', 'plant', 'location']));
    final firstFullPull = server.pulls.indexWhere((u) =>
        !u.queryParameters.containsKey('entities') &&
        u.queryParameters['limit'] != '1');
    expect(server.pulls.indexOf(essentialsPull), lessThan(firstFullPull),
        reason: 'the plants come before any of the history');

    final essentials =
        reports.whereType<SyncProgress>().where((p) => p.stage == SyncStage.essentials);
    expect(essentials.first.done, 0);
    expect(essentials.last.done, 5);
    expect(essentials.last.total, 5);

    final rest =
        reports.whereType<SyncProgress>().where((p) => p.stage == SyncStage.rest);
    expect(rest, isNotEmpty);
    expect(rest.every((p) => p.large), isTrue);
    expect(rest.last.done, 405);
    expect(rest.last.total, 405);
    expect(reports.last, isNull, reason: 'cleared once the pull ends');

    expect((await db.select(db.entriesTable).get()), hasLength(400));
    expect(result.pulled, 405, reason: 'the essentials counted once');
  });

  test('a fresh device facing a small garden pulls it in one go', () async {
    server = _FakeServer(_garden(entries: 150));

    await sync();

    expect(server.essentialsPulls, isEmpty);
    expect(reports.whereType<SyncProgress>().any((p) => p.large), isFalse);
    expect((await db.select(db.entriesTable).get()), hasLength(150));
  });

  test('a server that cannot count gets the essentials first all the same',
      () async {
    server = _FakeServer(_garden(entries: 150))..counts = false;

    await sync();

    expect(server.essentialsPulls, hasLength(1));
    final progress = reports.whereType<SyncProgress>();
    expect(progress.every((p) => p.total == null), isTrue);
    expect((await db.select(db.entriesTable).get()), hasLength(150));
  });

  test(
      'a device that already pulled skips the essentials; a big backlog '
      'is large, a small one is not', () async {
    server = _FakeServer(_garden(entries: 400));
    await DriftSyncCursorStore(db).setPullCursor(syncServerPeerId, 1);

    await sync();

    expect(server.essentialsPulls, isEmpty);
    expect(server.pulls.first.queryParameters['count'], '1');
    expect(
        server.pulls.skip(1).any((u) => u.queryParameters['count'] == '1'),
        isFalse,
        reason: 'counted once per pull');
    final rest = reports.whereType<SyncProgress>().toList();
    expect(rest.every((p) => p.stage == SyncStage.rest && p.large), isTrue);
    expect(rest.last.total, 404);

    reports.clear();
    server.rows.addAll([_entry('late1', 1000), _entry('late2', 1001)]);
    await sync();
    expect(reports.whereType<SyncProgress>().any((p) => p.large), isFalse);
  });

  test('without a size, a backlog turns large once it outgrows the threshold',
      () async {
    server = _FakeServer(_garden(entries: 400))..counts = false;
    await DriftSyncCursorStore(db).setPullCursor(syncServerPeerId, 1);

    await sync();

    final rest = reports.whereType<SyncProgress>().toList();
    expect(rest.first.large, isFalse);
    expect(rest.firstWhere((p) => p.large).done, largeSyncThreshold);
  });
}
