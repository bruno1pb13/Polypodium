import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:polypodium/core/sync/sync_exceptions.dart';
import 'package:polypodium/features/workspaces/data/mcp_token_client.dart';

void main() {
  const client = McpTokenClient();
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

  final tokenJson = {
    'id': 't1',
    'name': 'Claude',
    'tokenPrefix': 'pmcp_abcdef',
    'canWrite': true,
    'createdAt': '2026-10-12T10:00:00Z',
    'lastUsedAt': null,
    'userId': 'u1',
    'email': 'eu@x.com',
  };

  test('lists the garden\'s tokens', () async {
    final sent = <http.Request>[];
    final list = await withServer(
      () => client.listTokens(serverUrl: server, token: 'tok', gardenId: 'g1'),
      (_) => http.Response(
          jsonEncode({'enabled': false, 'tokens': [tokenJson]}), 200),
      sent: sent,
    );
    final tokens = list.tokens;
    expect(list.enabled, isFalse);
    expect(sent.single.url.toString(),
        '$server/api/v1/gardens/g1/mcp-tokens');
    expect(sent.single.headers['Authorization'], 'Bearer tok');
    expect(tokens.single.name, 'Claude');
    expect(tokens.single.canWrite, isTrue);
    expect(tokens.single.lastUsedAt, isNull);
    expect(tokens.single.createdAt, DateTime.utc(2026, 10, 12, 10));
  });

  test('creates a token and returns its secret', () async {
    final sent = <http.Request>[];
    final created = await withServer(
      () => client.createToken(
          serverUrl: server,
          token: 'tok',
          gardenId: 'g1',
          name: 'Claude',
          canWrite: false),
      (_) => http.Response(
          jsonEncode({...tokenJson, 'token': 'pmcp_secret'}), 201),
      sent: sent,
    );
    expect(jsonDecode(sent.single.body), {'name': 'Claude', 'canWrite': false});
    expect(created.secret, 'pmcp_secret');
    expect(created.token.id, 't1');
  });

  test('revokes by id', () async {
    final sent = <http.Request>[];
    await withServer(
      () => client.revokeToken(
          serverUrl: server, token: 'tok', gardenId: 'g1', tokenId: 't1'),
      (_) => http.Response(jsonEncode({'ok': true}), 200),
      sent: sent,
    );
    expect(sent.single.method, 'DELETE');
    expect(sent.single.url.path, '/api/v1/gardens/g1/mcp-tokens/t1');
  });

  test('reports MCP turned off by the admins', () async {
    expect(
      withServer(
        () => client.createToken(
            serverUrl: server,
            token: 'tok',
            gardenId: 'g1',
            name: 'x',
            canWrite: false),
        (_) => http.Response(
            jsonEncode({'error': 'MCP is disabled', 'code': 'mcp_disabled'}),
            403),
      ),
      throwsA(isA<McpDisabledException>()),
    );
    // A server from before the switch omits `enabled`: MCP was always on.
    final list = await withServer(
      () => client.listTokens(serverUrl: server, token: 'tok', gardenId: 'g1'),
      (_) => http.Response(jsonEncode({'tokens': []}), 200),
    );
    expect(list.enabled, isTrue);
  });

  test('tells an old server from a lost garden', () async {
    expect(
      withServer(
        () =>
            client.listTokens(serverUrl: server, token: 'tok', gardenId: 'g1'),
        (_) => http.Response('Route not found', 404),
      ),
      throwsA(isA<McpUnsupportedException>()),
    );
    expect(
      withServer(
        () =>
            client.listTokens(serverUrl: server, token: 'tok', gardenId: 'g1'),
        (_) => http.Response(jsonEncode({'error': 'garden not found'}), 404),
      ),
      throwsA(isA<GardenAccessDeniedException>()),
    );
    expect(
      withServer(
        () =>
            client.listTokens(serverUrl: server, token: 'tok', gardenId: 'g1'),
        (_) => http.Response('', 401),
      ),
      throwsA(isA<SessionExpiredException>()),
    );
  });
}
