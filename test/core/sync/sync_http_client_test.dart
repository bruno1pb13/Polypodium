import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:polypodium/core/enums.dart';
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
    expect(sent.headers[entryTypesHeader]!.split(','),
        EntryType.values.map((t) => t.name).toList());
    expect(sent.headers[entryTypesHeader], contains('repotting'));
  });
}
