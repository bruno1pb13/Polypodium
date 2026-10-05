import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/sync/sync_exceptions.dart';
import '../domain/garden.dart';

/// Talks to a Polypodium server's garden endpoints (`/api/v1/gardens/*`):
/// which gardens an account belongs to and who shares them.
class GardenClient {
  const GardenClient();

  /// Gardens the account belongs to, its personal one first. Throws
  /// [GardensUnsupportedException] on a server predating gardens.
  Future<List<Garden>> listGardens({
    required String serverUrl,
    required String token,
  }) async {
    final response = await http
        .get(Uri.parse('$serverUrl/api/v1/gardens'),
            headers: _authHeaders(token))
        .timeout(const Duration(seconds: 10));
    if (response.statusCode == 404) {
      throw const GardensUnsupportedException();
    }
    _checkStatus(response, 200);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return (data['gardens'] as List<dynamic>)
        .map((g) => Garden.fromJson(g as Map<String, dynamic>))
        .toList();
  }

  Future<Garden> createGarden({
    required String serverUrl,
    required String token,
    required String name,
  }) async {
    final response = await http
        .post(Uri.parse('$serverUrl/api/v1/gardens'),
            headers: _authHeaders(token), body: jsonEncode({'name': name}))
        .timeout(const Duration(seconds: 15));
    if (response.statusCode == 404) {
      throw const GardensUnsupportedException();
    }
    _checkStatus(response, 201);
    return Garden.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<List<GardenMember>> listMembers({
    required String serverUrl,
    required String token,
    required String gardenId,
  }) async {
    final response = await http
        .get(Uri.parse('$serverUrl/api/v1/gardens/$gardenId/members'),
            headers: _authHeaders(token))
        .timeout(const Duration(seconds: 10));
    _checkStatus(response, 200);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return (data['members'] as List<dynamic>)
        .map((m) => GardenMember.fromJson(m as Map<String, dynamic>))
        .toList();
  }

  /// Adds the account registered on this server under [email].
  Future<void> addMember({
    required String serverUrl,
    required String token,
    required String gardenId,
    required String email,
  }) async {
    final response = await http
        .post(Uri.parse('$serverUrl/api/v1/gardens/$gardenId/members'),
            headers: _authHeaders(token), body: jsonEncode({'email': email}))
        .timeout(const Duration(seconds: 15));
    if (response.statusCode == 404) {
      throw const GardenAccountNotFoundException();
    }
    if (response.statusCode == 409) {
      throw const GardenAlreadyMemberException();
    }
    _checkStatus(response, 201);
  }

  /// Removes [userId] from the garden; with the caller's own id, leaves it.
  Future<void> removeMember({
    required String serverUrl,
    required String token,
    required String gardenId,
    required String userId,
  }) async {
    final response = await http
        .delete(
            Uri.parse('$serverUrl/api/v1/gardens/$gardenId/members/$userId'),
            headers: _authHeaders(token))
        .timeout(const Duration(seconds: 15));
    _checkStatus(response, 200);
  }

  void _checkStatus(http.Response response, int expected) {
    if (response.statusCode == 401) {
      throw const SessionExpiredException();
    }
    if (response.statusCode != expected) {
      String? message;
      try {
        message = (jsonDecode(response.body) as Map<String, dynamic>)['error']
            as String?;
      } catch (_) {}
      throw ServerErrorException(message);
    }
  }

  Map<String, String> _authHeaders(String token) => {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };
}
