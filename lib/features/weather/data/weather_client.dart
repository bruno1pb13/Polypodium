import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/sync/sync_exceptions.dart';
import '../../../core/sync/sync_http_client.dart';
import '../domain/location_weather.dart';

/// Reads forecasts the server keeps for locations with coordinates.
class WeatherClient {
  const WeatherClient();

  /// The forecast for [locationId] in the workspace's garden, or null when
  /// the server has none for it (weather off, no coordinates, location not
  /// synced yet, or not fetched yet).
  Future<LocationWeather?> forLocation({
    required String serverUrl,
    required String token,
    required String? gardenId,
    required String locationId,
  }) async {
    final response = await http.get(
      Uri.parse('$serverUrl/api/v1/weather/locations/'
          '${Uri.encodeComponent(locationId)}?days=0'),
      headers: {
        'Authorization': 'Bearer $token',
        ...gardenHeaders(gardenId),
      },
    ).timeout(const Duration(seconds: 10));
    if (response.statusCode == 401) throw const SessionExpiredException();
    if (response.statusCode == 404) return null;
    if (response.statusCode != 200) {
      throw ServerErrorException('HTTP ${response.statusCode}');
    }
    return LocationWeather.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }
}
