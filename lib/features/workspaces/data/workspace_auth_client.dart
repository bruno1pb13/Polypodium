import 'dart:convert';

import 'package:http/http.dart' as http;

class WorkspaceLoginResult {
  final String token;
  final String deviceId;
  const WorkspaceLoginResult({required this.token, required this.deviceId});
}

/// Talks to a Polypodium server's auth endpoints. Extracted out of
/// SyncService because creating a new remote workspace needs to authenticate
/// before that workspace (and the SyncService tied to it) exists.
class WorkspaceAuthClient {
  const WorkspaceAuthClient();

  Future<void> checkServer(String serverUrl) async {
    final response = await http
        .get(Uri.parse('$serverUrl/api/v1/health'))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Servidor não disponível ou URL inválida');
    }
  }

  /// Whether [serverUrl] already has at least one registered account. Used
  /// to decide whether to show a login form or the first-account onboarding.
  Future<bool> hasUsers(String serverUrl) async {
    final response = await http
        .get(Uri.parse('$serverUrl/api/v1/auth/status'))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Servidor não disponível ou URL inválida');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['hasUsers'] as bool? ?? true;
  }

  /// Creates a new account on [serverUrl]. Only meant to be used when
  /// [hasUsers] returned false — the server treats every account the same,
  /// but the app only offers this as the very first-run onboarding step.
  Future<WorkspaceLoginResult> register({
    required String serverUrl,
    required String email,
    required String password,
  }) async {
    final response = await http
        .post(
          Uri.parse('$serverUrl/api/v1/auth/register'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'password': password}),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 201) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(body['error'] ?? 'Falha ao criar conta');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return WorkspaceLoginResult(
      token: data['token'] as String,
      deviceId: data['deviceId'] as String,
    );
  }

  Future<WorkspaceLoginResult> login({
    required String serverUrl,
    required String email,
    required String password,
    required String deviceId,
  }) async {
    final response = await http
        .post(
          Uri.parse('$serverUrl/api/v1/auth/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': email,
            'password': password,
            'deviceId': deviceId,
            'deviceName': 'Polypodium',
          }),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(body['error'] ?? 'Falha ao autenticar');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return WorkspaceLoginResult(
      token: data['token'] as String,
      deviceId: data['deviceId'] as String,
    );
  }
}
