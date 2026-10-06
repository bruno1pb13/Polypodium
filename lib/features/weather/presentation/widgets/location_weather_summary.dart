import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../locations/domain/location_model.dart';
import '../../domain/location_weather.dart';
import '../../domain/season.dart';
import '../providers/weather_providers.dart';

/// Season and, when the server provides it, today's forecast plus the next
/// few days for a location. Shows nothing for a location without
/// coordinates.
class LocationWeatherSummary extends ConsumerWidget {
  const LocationWeatherSummary({
    super.key,
    required this.location,
    required this.color,
    this.now,
  });

  final LocationModel location;

  /// Text and icon color, matching the card's secondary text.
  final Color color;

  /// Overrides the current date (tests).
  final DateTime? now;

  static const _upcomingDays = 3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lat = location.latitude;
    if (lat == null || location.longitude == null) {
      return const SizedBox.shrink();
    }
    final today = now ?? DateTime.now();
    final season = seasonAt(today, lat);
    final days = ref
            .watch(locationWeatherProvider(location.id))
            .value
            ?.fromDay(today) ??
        const <DailyWeather>[];
    final l10n = context.l10n;
    final style = TextStyle(fontSize: 12, color: color);

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _IconText(
                icon: _seasonIcon(season.current),
                text: l10n.seasonNextIn(
                  _seasonName(l10n, season.current),
                  _seasonName(l10n, season.next).toLowerCase(),
                  season.daysUntilNext,
                ),
                style: style,
              ),
              if (days.isNotEmpty) ..._today(context, days.first, style),
            ],
          ),
          if (days.length > 1) ...[
            const SizedBox(height: 4),
            Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [
                for (final day in days.skip(1).take(_upcomingDays))
                  _upcoming(context, day, style),
              ],
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _today(BuildContext context, DailyWeather day, TextStyle style) {
    final kind = weatherKindFor(day.weatherCode);
    final rain =
        _rainText(day, Localizations.localeOf(context).toString());
    return [
      Tooltip(
        message: kind == null ? '' : _weatherLabel(context.l10n, kind),
        child: _IconText(
          icon: _weatherIcon(kind),
          text: '${context.l10n.weatherToday} ${_range(day)}',
          style: style,
        ),
      ),
      if (rain != null)
        _IconText(icon: Icons.water_drop_outlined, text: rain, style: style),
    ];
  }

  Widget _upcoming(BuildContext context, DailyWeather day, TextStyle style) {
    final date = day.day;
    final weekday = date == null
        ? day.date
        : DateFormat.E(Localizations.localeOf(context).toString()).format(date);
    final kind = weatherKindFor(day.weatherCode);
    return Tooltip(
      message: kind == null ? '' : _weatherLabel(context.l10n, kind),
      child: _IconText(
        icon: _weatherIcon(kind),
        text: '$weekday ${_range(day)}',
        style: style.copyWith(fontSize: 11),
        iconSize: 13,
      ),
    );
  }

  static String _range(DailyWeather day) {
    String t(double? v) => v == null ? '–' : '${v.round()}°';
    return '${t(day.temperatureMax)}/${t(day.temperatureMin)}';
  }

  static String? _rainText(DailyWeather day, String locale) {
    final prob = day.precipitationProbabilityMax;
    final mm = day.precipitationSum;
    final parts = [
      if (prob != null) '${prob.round()}%',
      if (mm != null && mm > 0)
        '${NumberFormat(mm < 10 ? '0.0' : '0', locale).format(mm)} mm',
    ];
    return parts.isEmpty ? null : parts.join(' · ');
  }

  static IconData _seasonIcon(Season s) => switch (s) {
        Season.spring => Icons.local_florist_outlined,
        Season.summer => Icons.light_mode_outlined,
        Season.autumn => Icons.eco_outlined,
        Season.winter => Icons.ac_unit,
      };

  static String _seasonName(AppLocalizations l10n, Season s) => switch (s) {
        Season.spring => l10n.seasonSpring,
        Season.summer => l10n.seasonSummer,
        Season.autumn => l10n.seasonAutumn,
        Season.winter => l10n.seasonWinter,
      };

  static IconData _weatherIcon(WeatherKind? kind) => switch (kind) {
        WeatherKind.clear => Icons.wb_sunny_outlined,
        WeatherKind.partlyCloudy => Icons.wb_cloudy_outlined,
        WeatherKind.cloudy => Icons.cloud_outlined,
        WeatherKind.fog => Icons.foggy,
        WeatherKind.drizzle => Icons.grain,
        WeatherKind.rain => Icons.umbrella_outlined,
        WeatherKind.snow => Icons.ac_unit,
        WeatherKind.showers => Icons.umbrella_outlined,
        WeatherKind.thunderstorm => Icons.thunderstorm_outlined,
        null => Icons.thermostat_outlined,
      };

  static String _weatherLabel(AppLocalizations l10n, WeatherKind kind) =>
      switch (kind) {
        WeatherKind.clear => l10n.weatherClear,
        WeatherKind.partlyCloudy => l10n.weatherPartlyCloudy,
        WeatherKind.cloudy => l10n.weatherCloudy,
        WeatherKind.fog => l10n.weatherFog,
        WeatherKind.drizzle => l10n.weatherDrizzle,
        WeatherKind.rain => l10n.weatherRain,
        WeatherKind.snow => l10n.weatherSnow,
        WeatherKind.showers => l10n.weatherShowers,
        WeatherKind.thunderstorm => l10n.weatherThunderstorm,
      };
}

class _IconText extends StatelessWidget {
  const _IconText({
    required this.icon,
    required this.text,
    required this.style,
    this.iconSize = 14,
  });

  final IconData icon;
  final String text;
  final TextStyle style;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: iconSize, color: style.color),
        const SizedBox(width: 4),
        Flexible(child: Text(text, style: style)),
      ],
    );
  }
}
