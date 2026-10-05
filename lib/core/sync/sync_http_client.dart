import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:polypodium_core/polypodium_core.dart';

import '../enums.dart';
import 'sync_exceptions.dart';

/// Declares every [EntryType] this build can parse (unless a backfill pull
/// narrows it), so the server withholds the ones it can't. Without it the
/// server assumes a pre-header release and only sends the original types
/// (see Polypodium_server's docs/api.md).
const entryTypesHeader = 'X-Polypodium-Entry-Types';

class ChangesPage {
  final List<SyncChange> changes;
  final int nextCursor;
  final bool hasMore;

  /// The entity restriction as echoed by the server; null when none was
  /// asked for, or the server predates it and sent every entity.
  final Set<String>? entities;
  const ChangesPage(
      {required this.changes,
      required this.nextCursor,
      required this.hasMore,
      this.entities});
}

/// Pure HTTP transport for the sync protocol -- no storage or merge logic,
/// just request/response shapes. The server exposes the same
/// `/sync/changes` + `/sync/receive` + `/sync/ack` contract this client
/// calls; see Polypodium_server's sync_handler.dart.
class SyncHttpClient {
  const SyncHttpClient();

  Future<ChangesPage> fetchChanges({
    required String serverUrl,
    required String token,
    required int since,
    int limit = 100,
    Set<String>? entryTypes,
    Set<String>? entities,
  }) async {
    final query = 'since=$since&limit=$limit'
        '${entities == null ? '' : '&entities=${entities.join(',')}'}';
    final response = await http
        .get(
          Uri.parse('$serverUrl/api/v1/sync/changes?$query'),
          headers: {
            ..._authHeaders(token),
            entryTypesHeader:
                (entryTypes ?? EntryType.values.map((t) => t.name)).join(','),
          },
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 401) {
      throw const SessionExpiredException();
    }
    if (response.statusCode != 200) {
      throw const SyncReceiveException();
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final changes = (data['changes'] as List<dynamic>)
        .map((c) => SyncChange.fromJson(c as Map<String, dynamic>))
        .toList();

    return ChangesPage(
      changes: changes,
      nextCursor: data['nextCursor'] as int,
      hasMore: data['hasMore'] as bool? ?? false,
      entities: (data['entities'] as List<dynamic>?)?.cast<String>().toSet(),
    );
  }

  Future<int> receiveChanges({
    required String serverUrl,
    required String token,
    required String deviceId,
    required List<SyncChange> changes,
  }) async {
    final response = await http
        .post(
          Uri.parse('$serverUrl/api/v1/sync/receive'),
          headers: _authHeaders(token),
          body: jsonEncode({
            'deviceId': deviceId,
            'changes': changes.map((c) => c.toJson()).toList(),
          }),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 401) {
      throw const SessionExpiredException();
    }
    if (response.statusCode != 200) {
      throw const SyncSendException();
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['appliedCount'] as int? ?? 0;
  }

  /// Best-effort: failures here don't affect correctness, only the
  /// server's own `/sync/status` bookkeeping, so callers may ignore errors.
  Future<void> ack({
    required String serverUrl,
    required String token,
    required String deviceId,
    required int cursor,
  }) async {
    await http
        .post(
          Uri.parse('$serverUrl/api/v1/sync/ack'),
          headers: _authHeaders(token),
          body: jsonEncode({'deviceId': deviceId, 'cursor': cursor}),
        )
        .timeout(const Duration(seconds: 10));
  }

  Map<String, String> _authHeaders(String token) => {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };
}
