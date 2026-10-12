import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/sync/sync_exceptions.dart';
import '../domain/mcp_token.dart';

/// Talks to a Polypodium server's MCP token endpoints
/// (`/api/v1/gardens/<id>/mcp-tokens`): the tokens AI assistants connect to
/// one garden with.
class McpTokenClient {
  const McpTokenClient();

  /// The caller's tokens in the garden (everyone's for the owner), and
  /// whether the server's admins have MCP turned on. Throws
  /// [McpUnsupportedException] on a server predating MCP.
  Future<McpTokenList> listTokens({
    required String serverUrl,
    required String token,
    required String gardenId,
  }) async {
    final response = await http
        .get(_uri(serverUrl, gardenId), headers: _authHeaders(token))
        .timeout(const Duration(seconds: 10));
    _checkStatus(response, 200);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return (
      // Servers from before the switch had MCP always on.
      enabled: data['enabled'] as bool? ?? true,
      tokens: (data['tokens'] as List<dynamic>)
          .map((t) => McpToken.fromJson(t as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<CreatedMcpToken> createToken({
    required String serverUrl,
    required String token,
    required String gardenId,
    required String name,
    required bool canWrite,
  }) async {
    final response = await http
        .post(_uri(serverUrl, gardenId),
            headers: _authHeaders(token),
            body: jsonEncode({'name': name, 'canWrite': canWrite}))
        .timeout(const Duration(seconds: 15));
    _checkStatus(response, 201);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return (token: McpToken.fromJson(data), secret: data['token'] as String);
  }

  Future<void> revokeToken({
    required String serverUrl,
    required String token,
    required String gardenId,
    required String tokenId,
  }) async {
    final response = await http
        .delete(Uri.parse('${_uri(serverUrl, gardenId)}/$tokenId'),
            headers: _authHeaders(token))
        .timeout(const Duration(seconds: 15));
    _checkStatus(response, 200);
  }

  Uri _uri(String serverUrl, String gardenId) =>
      Uri.parse('$serverUrl/api/v1/gardens/$gardenId/mcp-tokens');

  void _checkStatus(http.Response response, int expected) {
    if (response.statusCode == 401) {
      throw const SessionExpiredException();
    }
    if (response.statusCode == expected) return;
    String? message;
    String? code;
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      message = body['error'] as String?;
      code = body['code'] as String?;
    } catch (_) {}
    if (code == 'mcp_disabled') throw const McpDisabledException();
    if (response.statusCode == 404) {
      // A JSON 404 comes from the garden routes (not a member anymore, or
      // a token already gone); a bare one means the route doesn't exist.
      if (message == 'garden not found') {
        throw const GardenAccessDeniedException();
      }
      if (message == null) throw const McpUnsupportedException();
    }
    throw ServerErrorException(message);
  }

  Map<String, String> _authHeaders(String token) => {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };
}
