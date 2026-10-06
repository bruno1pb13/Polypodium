/// Forecast for one location as served by `GET /api/v1/weather/locations/<id>`.
/// Dates are the location's local dates (`yyyy-MM-dd`).
class LocationWeather {
  const LocationWeather({required this.daily, this.fetchedAt});

  final List<DailyWeather> daily;
  final DateTime? fetchedAt;

  factory LocationWeather.fromJson(Map<String, dynamic> json) =>
      LocationWeather(
        fetchedAt: DateTime.tryParse(json['fetchedAt'] as String? ?? ''),
        daily: [
          for (final d in json['daily'] as List<dynamic>? ?? const [])
            DailyWeather.fromJson(d as Map<String, dynamic>),
        ],
      );

  /// The rows from [today] onwards (today first); [today] is matched by date
  /// only.
  List<DailyWeather> fromDay(DateTime today) {
    final key = DailyWeather.dateKey(today);
    return daily.where((d) => d.date.compareTo(key) >= 0).toList();
  }
}

class DailyWeather {
  const DailyWeather({
    required this.date,
    this.weatherCode,
    this.temperatureMax,
    this.temperatureMin,
    this.precipitationSum,
    this.precipitationProbabilityMax,
  });

  final String date;

  /// WMO weather interpretation code.
  final int? weatherCode;
  final double? temperatureMax;
  final double? temperatureMin;
  final double? precipitationSum;
  final double? precipitationProbabilityMax;

  DateTime? get day => DateTime.tryParse(date);

  static String dateKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  factory DailyWeather.fromJson(Map<String, dynamic> json) => DailyWeather(
        date: json['date'] as String,
        weatherCode: (json['weatherCode'] as num?)?.toInt(),
        temperatureMax: (json['temperatureMax'] as num?)?.toDouble(),
        temperatureMin: (json['temperatureMin'] as num?)?.toDouble(),
        precipitationSum: (json['precipitationSum'] as num?)?.toDouble(),
        precipitationProbabilityMax:
            (json['precipitationProbabilityMax'] as num?)?.toDouble(),
      );
}

/// Broad groups of WMO codes, enough to pick an icon and a label.
enum WeatherKind {
  clear,
  partlyCloudy,
  cloudy,
  fog,
  drizzle,
  rain,
  snow,
  showers,
  thunderstorm,
}

WeatherKind? weatherKindFor(int? code) => switch (code) {
      null => null,
      0 => WeatherKind.clear,
      1 || 2 => WeatherKind.partlyCloudy,
      3 => WeatherKind.cloudy,
      45 || 48 => WeatherKind.fog,
      >= 51 && <= 57 => WeatherKind.drizzle,
      >= 61 && <= 67 => WeatherKind.rain,
      >= 71 && <= 77 || 85 || 86 => WeatherKind.snow,
      >= 80 && <= 82 => WeatherKind.showers,
      >= 95 && <= 99 => WeatherKind.thunderstorm,
      _ => null,
    };
