import 'package:flutter_test/flutter_test.dart';
import 'package:polypodium/features/weather/domain/location_weather.dart';
import 'package:polypodium/features/weather/domain/season.dart';

void main() {
  group('seasonAt', () {
    test('southern hemisphere: spring from late September', () {
      final s = seasonAt(DateTime(2026, 10, 6), -23.5);
      expect(s.current, Season.spring);
      expect(s.next, Season.summer);
      expect(s.daysUntilNext, 76); // Dec 21
    });

    test('northern hemisphere is the opposite', () {
      final s = seasonAt(DateTime(2026, 10, 6), 48.8);
      expect(s.current, Season.autumn);
      expect(s.next, Season.winter);
    });

    test('a season starts on its boundary day', () {
      expect(seasonAt(DateTime(2026, 6, 21), -10).current, Season.winter);
      expect(seasonAt(DateTime(2026, 6, 20), -10).current, Season.autumn);
    });

    test('wraps around the turn of the year', () {
      final s = seasonAt(DateTime(2026, 1, 15), -30);
      expect(s.current, Season.summer);
      expect(s.next, Season.autumn);
      expect(s.daysUntilNext, 64); // Mar 20

      final late = seasonAt(DateTime(2026, 12, 25), 40);
      expect(late.current, Season.winter);
      expect(late.next, Season.spring);
    });
  });

  group('weatherKindFor', () {
    test('groups WMO codes', () {
      expect(weatherKindFor(0), WeatherKind.clear);
      expect(weatherKindFor(2), WeatherKind.partlyCloudy);
      expect(weatherKindFor(3), WeatherKind.cloudy);
      expect(weatherKindFor(45), WeatherKind.fog);
      expect(weatherKindFor(53), WeatherKind.drizzle);
      expect(weatherKindFor(63), WeatherKind.rain);
      expect(weatherKindFor(75), WeatherKind.snow);
      expect(weatherKindFor(86), WeatherKind.snow);
      expect(weatherKindFor(81), WeatherKind.showers);
      expect(weatherKindFor(95), WeatherKind.thunderstorm);
      expect(weatherKindFor(null), isNull);
      expect(weatherKindFor(42), isNull);
    });
  });

  test('LocationWeather parses the server response and skips past days', () {
    final weather = LocationWeather.fromJson({
      'fetchedAt': '2026-10-06T12:00:00.000Z',
      'daily': [
        {'date': '2026-10-05', 'temperatureMax': 20},
        {
          'date': '2026-10-06',
          'weatherCode': 61,
          'temperatureMax': 24.4,
          'temperatureMin': 16,
          'precipitationSum': 3,
          'precipitationProbabilityMax': 70,
        },
      ],
    });
    expect(weather.fetchedAt, DateTime.utc(2026, 10, 6, 12));
    final days = weather.fromDay(DateTime(2026, 10, 6, 23, 59));
    expect(days.single.date, '2026-10-06');
    expect(days.single.weatherCode, 61);
    expect(days.single.temperatureMin, 16.0);
    expect(days.single.precipitationProbabilityMax, 70.0);
  });
}
