import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:polypodium/core/sync/sync_exceptions.dart';
import 'package:polypodium/features/workspaces/data/garden_client.dart';

void main() {
  const client = GardenClient();
  const server = 'https://plantas.example';

  Future<T> withServer<T>(
    Future<T> Function() body,
    http.Response Function(http.Request request) respond, {
    List<http.Request>? sent,
  }) =>
      http.runWithClient(
        body,
        () => MockClient((request) async {
          sent?.add(request);
          return respond(request);
        }),
      );

  test('lists the account\'s gardens', () async {
    final sent = <http.Request>[];
    final gardens = await withServer(
      () => client.listGardens(serverUrl: server, token: 'tok'),
      (_) => http.Response(
          jsonEncode({
            'gardens': [
              {
                'id': 'u1',
                'name': '',
                'personal': true,
                'role': 'owner',
                'ownerUserId': 'u1',
                'ownerEmail': 'eu@x.com',
              },
              {
                'id': 'g1',
                'name': 'Horta',
                'personal': false,
                'role': 'member',
                'ownerUserId': 'u2',
                'ownerEmail': 'ela@x.com',
              },
            ]
          }),
          200),
      sent: sent,
    );

    expect(sent.single.url.path, '/api/v1/gardens');
    expect(sent.single.headers['Authorization'], 'Bearer tok');
    expect(gardens.map((g) => g.id), ['u1', 'g1']);
    expect(gardens.first.isOwnPersonal, isTrue);
    expect(gardens.last.isOwner, isFalse);
    expect(gardens.last.ownerEmail, 'ela@x.com');
  });

  test('a server predating gardens is reported as such', () async {
    await expectLater(
      withServer(() => client.listGardens(serverUrl: server, token: 't'),
          (_) => http.Response('Route not found', 404)),
      throwsA(isA<GardensUnsupportedException>()),
    );
  });

  test('adding a member maps the server refusals', () async {
    Future<void> add(int status) => withServer(
          () => client.addMember(
              serverUrl: server, token: 't', gardenId: 'g1', email: 'a@x.com'),
          (_) => http.Response(jsonEncode({'error': 'x'}), status),
        );

    await expectLater(add(404), throwsA(isA<GardenAccountNotFoundException>()));
    await expectLater(add(409), throwsA(isA<GardenAlreadyMemberException>()));
    await expectLater(add(403), throwsA(isA<ServerErrorException>()));
    await expectLater(add(401), throwsA(isA<SessionExpiredException>()));
    await add(201);
  });

  test('removing a member deletes their membership', () async {
    final sent = <http.Request>[];
    await withServer(
      () => client.removeMember(
          serverUrl: server, token: 't', gardenId: 'g1', userId: 'u2'),
      (_) => http.Response(jsonEncode({'ok': true}), 200),
      sent: sent,
    );
    expect(sent.single.method, 'DELETE');
    expect(sent.single.url.path, '/api/v1/gardens/g1/members/u2');
  });
}
