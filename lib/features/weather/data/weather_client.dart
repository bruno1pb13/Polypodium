import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/sync/sync_exceptions.dart';
import '../../../core/sync/sync_http_client.dart';
import '../domain/location_weather.dart';
import '../domain/watering_adjustment.dart';

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

  /// How the weather moves each plant's next watering in the workspace's
  /// garden. Empty when the server has weather off (404).
  Future<List<WateringAdjustment>> wateringAdvice({
    required String serverUrl,
    required String token,
    required String? gardenId,
    DateTime? now,
  }) async {
    final response = await http.get(
      Uri.parse('$serverUrl/api/v1/weather/watering'),
      headers: {
        'Authorization': 'Bearer $token',
        ...gardenHeaders(gardenId),
      },
    ).timeout(const Duration(seconds: 15));
    if (response.statusCode == 401) throw const SessionExpiredException();
    // Weather off, or a server from before this endpoint.
    if (response.statusCode == 404) return const [];
    if (response.statusCode != 200) {
      throw ServerErrorException('HTTP ${response.statusCode}');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final fetchedAt = now ?? DateTime.now();
    return [
      for (final p in body['plants'] as List<dynamic>? ?? const [])
        if (WateringAdjustment.fromJson(p as Map<String, dynamic>,
                fetchedAt: fetchedAt)
            case final adjustment?)
          adjustment,
    ];
  }
}
