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
      throw Exception(body['message'] ?? 'Falha ao autenticar');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return WorkspaceLoginResult(
      token: data['token'] as String,
      deviceId: data['deviceId'] as String,
    );
  }
}
