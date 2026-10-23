import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:polypodium_core/weather.dart';

/// Fetches forecasts straight from Open-Meteo, for the local workspace only
/// (a workspace with a server gets them from the server).
class OpenMeteoClient {
  const OpenMeteoClient({http.Client? client, this.baseUrl = openMeteoForecastUrl})
      : _client = client;

  final http.Client? _client;
  final String baseUrl;

  /// Past days of observations fetched along with the forecast: enough for
  /// the ET0 baseline and for long watering intervals.
  static const pastDays = 92;
  static const forecastDays = 7;

  /// The daily rows for one point. Throws [OpenMeteoException] when the
  /// request fails or the answer isn't a forecast.
  Future<WeatherForecast> fetch(double latitude, double longitude) async {
    final uri = Uri.parse(baseUrl).replace(
      queryParameters: openMeteoQuery(latitude, longitude,
          pastDays: pastDays, forecastDays: forecastDays, hourly: false),
    );
    final http.Response response;
    try {
      final client = _client;
      response = await (client == null ? http.get(uri) : client.get(uri))
          .timeout(const Duration(seconds: 30));
    } on Exception catch (e) {
      throw OpenMeteoException('request failed: $e');
    }
    final Object? decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      throw OpenMeteoException('HTTP ${response.statusCode}: invalid JSON');
    }
    if (decoded is! Map<String, dynamic>) {
      throw OpenMeteoException(
          'HTTP ${response.statusCode}: unexpected response');
    }
    if (response.statusCode != 200) {
      throw OpenMeteoException('HTTP ${response.statusCode}: '
          '${decoded['reason'] ?? 'request rejected'}');
    }
    return parseOpenMeteo(decoded);
  }
}

class OpenMeteoException implements Exception {
  OpenMeteoException(this.message);

  final String message;

  @override
  String toString() => 'OpenMeteoException: $message';
}
