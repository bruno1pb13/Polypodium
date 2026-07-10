import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/server_status.dart';
import '../domain/server_user.dart';

/// Talks to a Polypodium server's admin endpoints (`/api/v1/admin/*`).
/// Every call needs a token belonging to an account with role == 'admin' --
/// the server re-checks that on every request regardless of what the client
/// thinks the cached Workspace.role is.
class AdminClient {
  const AdminClient();

  /// The role of the account behind [token]. Any authenticated account can
  /// call this (not just admins) -- used to decide whether to show admin UI.
  Future<String> me({
    required String serverUrl,
    required String token,
  }) async {
    final response = await http
        .get(Uri.parse('$serverUrl/api/v1/admin/me'),
            headers: _authHeaders(token))
        .timeout(const Duration(seconds: 10));
    _checkStatus(response, 200);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['role'] as String;
  }

  Future<ServerStatus> status({
    required String serverUrl,
    required String token,
  }) async {
    final response = await http
        .get(Uri.parse('$serverUrl/api/v1/admin/status'),
            headers: _authHeaders(token))
        .timeout(const Duration(seconds: 10));
    _checkStatus(response, 200);
    return ServerStatus.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<List<ServerUser>> listUsers({
    required String serverUrl,
    required String token,
  }) async {
    final response = await http
        .get(Uri.parse('$serverUrl/api/v1/admin/users'),
            headers: _authHeaders(token))
        .timeout(const Duration(seconds: 15));
    _checkStatus(response, 200);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return (data['users'] as List<dynamic>)
        .map((u) => ServerUser.fromJson(u as Map<String, dynamic>))
        .toList();
  }

  Future<void> createUser({
    required String serverUrl,
    required String token,
    required String email,
    required String password,
  }) async {
    final response = await http
        .post(
          Uri.parse('$serverUrl/api/v1/admin/users'),
          headers: _authHeaders(token),
          body: jsonEncode({'email': email, 'password': password}),
        )
        .timeout(const Duration(seconds: 15));
    _checkStatus(response, 201);
  }

  Future<void> setRole({
    required String serverUrl,
    required String token,
    required String userId,
    required String role,
  }) async {
    final response = await http
        .patch(
          Uri.parse('$serverUrl/api/v1/admin/users/$userId/role'),
          headers: _authHeaders(token),
          body: jsonEncode({'role': role}),
        )
        .timeout(const Duration(seconds: 15));
    _checkStatus(response, 200);
  }

  Future<void> setDisabled({
    required String serverUrl,
    required String token,
    required String userId,
    required bool disabled,
  }) async {
    final response = await http
        .patch(
          Uri.parse('$serverUrl/api/v1/admin/users/$userId/status'),
          headers: _authHeaders(token),
          body: jsonEncode({'disabled': disabled}),
        )
        .timeout(const Duration(seconds: 15));
    _checkStatus(response, 200);
  }

  void _checkStatus(http.Response response, int expected) {
    if (response.statusCode == 401) {
      throw Exception('Sessão expirada. Faça login novamente.');
    }
    if (response.statusCode == 403) {
      throw Exception('Você não tem permissão de administrador.');
    }
    if (response.statusCode != expected) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(body['error'] ?? 'Erro ao comunicar com o servidor');
    }
  }

  Map<String, String> _authHeaders(String token) => {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };
}
