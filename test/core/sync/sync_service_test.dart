import 'dart:async';
import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:polypodium/core/database/app_database.dart';
import 'package:polypodium/core/storage/photo_storage.dart';
import 'package:polypodium/core/sync/sync_service.dart';
import 'package:polypodium/core/sync/workspace_config_store.dart';
import 'package:polypodium/features/workspaces/domain/workspace_model.dart';

class _Store implements WorkspaceConfigStore {
  _Store(this.current);

  @override
  Workspace current;

  @override
  Future<void> save(Workspace updated) async => current = updated;
}

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() async => db.close());

  test(
      'calls during a sync join it and get a single pass more, and the '
      'progress is cleared at the end', () async {
    final gate = Completer<void>();
    var fullPulls = 0;
    final reports = <SyncProgress?>[];
    final service = SyncService(
      db,
      _Store(Workspace(
        id: 'remote-1',
        name: 'Server',
        type: WorkspaceType.remote,
        serverUrl: 'https://example.test',
        token: 'tok',
        deviceId: 'dev-1',
        createdAt: DateTime(2026, 1, 1),
      )),
      PhotoStorage(baseDirName: 'test_photos'),
      onProgress: reports.add,
    );

    final client = MockClient((request) async {
      final path = request.url.path;
      if (path == '/api/v1/sync/changes') {
        // The probe of a fresh device asks for a single row.
        if (request.url.queryParameters['limit'] != '1') {
          fullPulls++;
          await gate.future;
        }
        return http.Response(
            jsonEncode({'changes': [], 'nextCursor': 0, 'hasMore': false}),
            200);
      }
      return http.Response(jsonEncode({'ok': true}), 200);
    });

    await http.runWithClient(() async {
      final first = service.sync();
      final second = service.sync();
      final third = service.sync();
      expect(identical(first, second), isTrue);
      expect(identical(first, third), isTrue);

      gate.complete();
      await first;
      expect(fullPulls, 2, reason: 'one pass, plus one for the joiners');
      expect(reports.last, isNull);

      await service.sync();
      expect(fullPulls, 3, reason: 'a later call starts a sync of its own');
    }, () => client);
  });
}
