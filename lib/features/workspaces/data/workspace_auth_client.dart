import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/sync/sync_exceptions.dart';

class WorkspaceLoginResult {
  final String token;
  final String deviceId;
  final String? role;
  const WorkspaceLoginResult({
    required this.token,
    required this.deviceId,
    this.role,
  });
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
      throw const ServerUnavailableException();
    }
  }

  /// Whether [serverUrl] already has at least one registered account. Used
  /// to decide whether to show a login form or the first-account onboarding.
  Future<bool> hasUsers(String serverUrl) async {
    final response = await http
        .get(Uri.parse('$serverUrl/api/v1/auth/status'))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw const ServerUnavailableException();
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['hasUsers'] as bool? ?? true;
  }

  /// Creates the very first account on [serverUrl], which becomes the
  /// server's admin. Only works when [hasUsers] returned false — the server
  /// rejects this once any account exists; after that, only an existing
  /// admin can create new accounts (see AdminClient.createUser).
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
      throw AuthFailedException(
        serverMessage: body['error'] as String?,
        isRegistration: true,
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return WorkspaceLoginResult(
      token: data['token'] as String,
      deviceId: data['deviceId'] as String,
      role: data['role'] as String?,
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
      throw AuthFailedException(serverMessage: body['error'] as String?);
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return WorkspaceLoginResult(
      token: data['token'] as String,
      deviceId: data['deviceId'] as String,
      role: data['role'] as String?,
    );
  }
}
