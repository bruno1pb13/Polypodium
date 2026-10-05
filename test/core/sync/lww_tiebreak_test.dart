import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:polypodium_core/polypodium_core.dart';

import 'package:polypodium/core/database/app_database.dart';
import 'package:polypodium/core/sync/drift_sync_storage_adapter.dart';

// Lowercase UUIDs, the format the server issues.
const _deviceLow = '1b4e28ba-2fa1-41d2-883f-0016d3cca427';
const _deviceHigh = 'f47ac10b-58cc-4372-a567-0e02b2c3d479';

final _t = DateTime.utc(2026, 3, 1, 12);

/// A local edit of location `loc1` at exactly [updatedAt], stamped like the
/// repositories do.
Future<void> _localEdit(AppDatabase db, String name, DateTime updatedAt) =>
    db.transaction(() async {
      final rev = await db.syncMetaDao.nextRev();
      await db.locationsDao.upsert(LocationsTableCompanion.insert(
        id: 'loc1',
        name: name,
        createdAt: DateTime.utc(2026, 1, 1),
        updatedAt: updatedAt,
        localRev: Value(rev),
        deviceId: Value(db.deviceId),
      ));
    });

SyncChange _remote(String name, String deviceId, {DateTime? updatedAt}) =>
    SyncChange(
      entityType: 'location',
      entityId: 'loc1',
      payload: {
        'id': 'loc1',
        'name': name,
        'createdAt': DateTime.utc(2026, 1, 1).toIso8601String(),
      },
      updatedAt: updatedAt ?? _t,
      deviceId: deviceId,
      rev: 1,
    );

/// In-memory stand-in for the server's mat_* table, applying the same
/// `ON CONFLICT` rule (`incomingWins`) and handing out a global rev.
class _FakeServer {
  final _rows = <String, SyncChange>{};
  var _rev = 0;

  void receive(List<SyncChange> changes) {
    for (final c in changes) {
      final current = _rows[c.entityId];
      if (!incomingWins(
        incomingUpdatedAt: c.updatedAt,
        incomingDeviceId: c.deviceId,
        currentUpdatedAt: current?.updatedAt,
        currentDeviceId: current?.deviceId,
      )) {
        continue;
      }
      _rows[c.entityId] = SyncChange(
        entityType: c.entityType,
        entityId: c.entityId,
        payload: c.payload,
        updatedAt: c.updatedAt,
        deletedAt: c.deletedAt,
        deviceId: c.deviceId,
        rev: ++_rev,
      );
    }
  }

  List<SyncChange> changesSince(int since) =>
      _rows.values.where((c) => c.rev > since).toList()
        ..sort((a, b) => a.rev.compareTo(b.rev));
}

/// One replica with the push/pull cursors the orchestrator keeps.
class _Device {
  _Device(String deviceId)
      : db = AppDatabase.forTesting(NativeDatabase.memory(),
            deviceId: deviceId) {
    adapter = DriftSyncStorageAdapter(db);
  }

  final AppDatabase db;
  late final DriftSyncStorageAdapter adapter;
  var _pushed = 0;
  var _pulled = 0;

  Future<void> push(_FakeServer server) async {
    final changes = await adapter.localChangesSince(_pushed,
        limit: 100, deviceId: db.deviceId!);
    server.receive(changes);
    for (final c in changes) {
      if (c.rev > _pushed) _pushed = c.rev;
    }
  }

  Future<void> pull(_FakeServer server) async {
    for (final c in server.changesSince(_pulled)) {
      await adapter.applyRemoteChange(c);
      _pulled = c.rev;
    }
  }

  Future<LocationsTableData> location() async =>
      (await db.locationsDao.getById('loc1'))!;
}

void main() {
  group('pulling a change with the same updatedAt', () {
    late AppDatabase db;
    late DriftSyncStorageAdapter adapter;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory(), deviceId: 'unused');
      adapter = DriftSyncStorageAdapter(db);
    });

    tearDown(() async => db.close());

    Future<void> seed(String? deviceId) => db.locationsDao.upsert(
          LocationsTableCompanion.insert(
            id: 'loc1',
            name: 'Local',
            createdAt: DateTime.utc(2026, 1, 1),
            updatedAt: _t,
            deviceId: Value(deviceId),
          ),
        );

    test('applies it from a greater deviceId and records the sender', () async {
      await seed(_deviceLow);
      await adapter.applyRemoteChange(_remote('Remote', _deviceHigh));
      final row = (await db.locationsDao.getById('loc1'))!;
      expect(row.name, 'Remote');
      expect(row.deviceId, _deviceHigh);
    });

    test('ignores it from a smaller deviceId', () async {
      await seed(_deviceHigh);
      await adapter.applyRemoteChange(_remote('Remote', _deviceLow));
      final row = (await db.locationsDao.getById('loc1'))!;
      expect(row.name, 'Local');
      expect(row.deviceId, _deviceHigh);
    });

    test('treats an identical re-send as a no-op', () async {
      await seed(_deviceLow);
      await adapter.applyRemoteChange(_remote('Remote', _deviceLow));
      expect((await db.locationsDao.getById('loc1'))!.name, 'Local');
    });

    test('applies it over a row with no known writer', () async {
      await seed(null);
      await adapter.applyRemoteChange(_remote('Remote', _deviceLow));
      final row = (await db.locationsDao.getById('loc1'))!;
      expect(row.name, 'Remote');
      expect(row.deviceId, _deviceLow);
    });

    test('still applies a strictly newer change from a smaller deviceId',
        () async {
      await seed(_deviceHigh);
      await adapter.applyRemoteChange(_remote('Remote', _deviceLow,
          updatedAt: _t.add(const Duration(milliseconds: 1))));
      expect((await db.locationsDao.getById('loc1'))!.name, 'Remote');
    });
  });

  group('two devices editing at the same instant converge', () {
    late _Device low;
    late _Device high;
    late _FakeServer server;

    setUp(() async {
      low = _Device(_deviceLow);
      high = _Device(_deviceHigh);
      server = _FakeServer();
      await _localEdit(low.db, 'Base', DateTime.utc(2026, 1, 1));
      await low.push(server);
      await high.pull(server);
    });

    tearDown(() async {
      await low.db.close();
      await high.db.close();
    });

    Future<void> expectConverged(String name) async {
      final a = await low.location();
      final b = await high.location();
      expect(a.name, name);
      expect(b.name, name);
      expect(a.updatedAt, b.updatedAt);
      expect(a.deviceId, _deviceHigh);
      expect(b.deviceId, _deviceHigh);
      expect(server.changesSince(0).single.payload['name'], name);
    }

    for (final lowSyncsFirst in [true, false]) {
      test(lowSyncsFirst ? 'smaller deviceId syncs first' : 'greater first',
          () async {
        await _localEdit(low.db, 'From low', _t);
        await _localEdit(high.db, 'From high', _t);

        final first = lowSyncsFirst ? low : high;
        final second = lowSyncsFirst ? high : low;
        // The orchestrator pulls before pushing.
        await first.pull(server);
        await first.push(server);
        await second.pull(server);
        await second.push(server);
        await first.pull(server);
        await first.push(server);

        await expectConverged('From high');
      });
    }
  });
}
