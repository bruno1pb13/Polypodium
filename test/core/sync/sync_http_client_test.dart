import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:polypodium/core/enums.dart';
import 'package:polypodium/core/storage/photo_storage.dart';
import 'package:polypodium/core/sync/photo_sync_client.dart';
import 'package:polypodium/core/sync/sync_exceptions.dart';
import 'package:polypodium/core/sync/sync_http_client.dart';

void main() {
  test('fetchChanges declares every EntryType this build understands',
      () async {
    late http.Request sent;
    final client = MockClient((request) async {
      sent = request;
      return http.Response(
        jsonEncode({'changes': [], 'nextCursor': 0, 'hasMore': false}),
        200,
      );
    });

    await http.runWithClient(
      () => const SyncHttpClient().fetchChanges(
          serverUrl: 'https://example.test', token: 't', since: 0),
      () => client,
    );

    expect(sent.url.path, '/api/v1/sync/changes');
    expect(sent.url.queryParameters.containsKey('entities'), isFalse);
    expect(sent.headers[entryTypesHeader]!.split(','),
        EntryType.values.map((t) => t.name).toList());
    expect(sent.headers[entryTypesHeader], contains('repotting'));
  });

  test('fetchChanges can narrow the declared types and the entities, and '
      'reports the restriction the server echoed', () async {
    late http.Request sent;
    Map<String, dynamic> body = {
      'changes': [],
      'nextCursor': 0,
      'hasMore': false,
      'entities': ['entry'],
    };
    final client = MockClient((request) async {
      sent = request;
      return http.Response(jsonEncode(body), 200);
    });

    Future<ChangesPage> fetch() => http.runWithClient(
          () => const SyncHttpClient().fetchChanges(
              serverUrl: 'https://example.test',
              token: 't',
              since: 0,
              entryTypes: {'repotting'},
              entities: {'entry'}),
          () => client,
        );

    final page = await fetch();
    expect(sent.url.queryParameters['entities'], 'entry');
    expect(sent.headers[entryTypesHeader], 'repotting');
    expect(page.entities, {'entry'});

    body = {...body}..remove('entities');
    expect((await fetch()).entities, isNull);
  });

  test('the types the server stores and the ones it dropped are reported, '
      'or null when it predates that', () async {
    Map<String, dynamic> pullBody = {
      'changes': [],
      'nextCursor': 0,
      'hasMore': false,
      'supportedEntities': ['entry', 'plant'],
    };
    Map<String, dynamic> pushBody = {
      'appliedCount': 1,
      'ignoredEntityTypes': ['reminder'],
    };
    final client = MockClient((request) async => http.Response(
        jsonEncode(request.url.path.endsWith('/changes') ? pullBody : pushBody),
        200));

    Future<(ChangesPage, ReceiveResult)> sync() => http.runWithClient(
          () async => (
            await const SyncHttpClient().fetchChanges(
                serverUrl: 'https://example.test', token: 't', since: 0),
            await const SyncHttpClient().receiveChanges(
                serverUrl: 'https://example.test',
                token: 't',
                deviceId: 'd',
                changes: const []),
          ),
          () => client,
        );

    final (page, receipt) = await sync();
    expect(page.supportedEntities, {'entry', 'plant'});
    expect(receipt.appliedCount, 1);
    expect(receipt.ignoredEntityTypes, {'reminder'});

    pullBody = {...pullBody}..remove('supportedEntities');
    pushBody = {'appliedCount': 1};
    final (oldPage, oldReceipt) = await sync();
    expect(oldPage.supportedEntities, isNull);
    expect(oldReceipt.ignoredEntityTypes, isNull);
  });

  group('garden header', () {
    Future<List<http.Request>> requestsOf(
        SyncHttpClient client, PhotoSyncClient photos) async {
      final sent = <http.Request>[];
      final mock = MockClient((request) async {
        sent.add(request);
        return http.Response(
            jsonEncode(request.url.path.endsWith('/changes')
                ? {'changes': [], 'nextCursor': 0, 'hasMore': false}
                : {'appliedCount': 0, 'ok': true}),
            200);
      });
      await http.runWithClient(() async {
        const server = 'https://example.test';
        await client.fetchChanges(serverUrl: server, token: 't', since: 0);
        await client.receiveChanges(
            serverUrl: server, token: 't', deviceId: 'd', changes: const []);
        await client.ack(serverUrl: server, token: 't', deviceId: 'd', cursor: 1);
        // An existing photo is only probed with HEAD.
        await photos.upload(
            serverUrl: server,
            token: 't',
            entityId: 'e1',
            localPath: '/nowhere/e1.jpg',
            skipExisting: true);
      }, () => mock);
      return sent;
    }

    final storage = PhotoStorage(baseDirName: 'test_photos');

    test('is sent on every request of a workspace that names a garden',
        () async {
      final sent = await requestsOf(const SyncHttpClient(gardenId: 'g1'),
          PhotoSyncClient(storage, gardenId: 'g1'));
      expect(sent.map((r) => r.method), ['GET', 'POST', 'POST', 'HEAD']);
      for (final request in sent) {
        expect(request.headers[gardenHeader], 'g1', reason: request.url.path);
      }
    });

    test('is absent for the personal garden, as before gardens', () async {
      final sent = await requestsOf(
          const SyncHttpClient(), PhotoSyncClient(storage));
      expect(sent, hasLength(4));
      for (final request in sent) {
        expect(request.headers.containsKey(gardenHeader), isFalse,
            reason: request.url.path);
      }
    });

    test('a refused garden is reported as lost access', () async {
      final mock = MockClient(
          (_) async => http.Response(jsonEncode({'error': 'x'}), 403));
      Future<void> pull(SyncHttpClient client) => http.runWithClient(
          () => client.fetchChanges(
              serverUrl: 'https://example.test', token: 't', since: 0),
          () => mock);
      Future<void> push(SyncHttpClient client) => http.runWithClient(
          () => client.receiveChanges(
              serverUrl: 'https://example.test',
              token: 't',
              deviceId: 'd',
              changes: const []),
          () => mock);

      const shared = SyncHttpClient(gardenId: 'g1');
      await expectLater(
          pull(shared), throwsA(isA<GardenAccessDeniedException>()));
      await expectLater(
          push(shared), throwsA(isA<GardenAccessDeniedException>()));
      await expectLater(
          pull(const SyncHttpClient()), throwsA(isA<SyncReceiveException>()));
    });
  });
}
