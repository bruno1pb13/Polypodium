import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:polypodium_core/weather.dart' as shared;
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/notifications/notification_service.dart';
import '../../plants/data/plants_repository.dart';
import '../../species/data/species_repository.dart';
import '../domain/location_weather.dart';
import '../domain/watering_adjustment.dart';
import 'open_meteo_client.dart';

/// Weather for the local workspace, computed on this device: the forecast
/// comes straight from Open-Meteo and the watering advice follows the same
/// rules the server applies to remote gardens (polypodium_core). A
/// workspace with a server never runs this; it takes both from its server.
///
/// Nearby locations share one region and one fetch, as on the server, and
/// each region is fetched about once a day.
class LocalWeatherService {
  LocalWeatherService(
    this._db, {
    OpenMeteoClient client = const OpenMeteoClient(),
    INotificationService notifications = const NotificationService(),
    shared.WateringRules rules = const shared.WateringRules(),
    DateTime Function()? now,
  })  : _client = client,
        _rules = rules,
        _now = now ?? DateTime.now,
        _plantsRepo = PlantsRepository(_db, notifications);

  final AppDatabase _db;
  final OpenMeteoClient _client;
  final shared.WateringRules _rules;
  final DateTime Function() _now;
  final PlantsRepository _plantsRepo;

  /// Coordinates closer than this to a region's center use that region.
  static const clusterRadiusKm = 5.0;
  static const refreshInterval = Duration(hours: 24);
  static const retryInterval = Duration(hours: 1);

  /// Fetches the regions that are due, then recomputes the watering
  /// advice. Best effort: a failed fetch is recorded on its region and
  /// retried later, and never throws.
  Future<void> refresh() async {
    final now = _now();
    for (final region in await _assignRegions()) {
      if (_isDue(region, now)) await _fetch(region, now);
    }
    await recompute();
  }

  /// Recomputes the watering advice from the stored forecasts, without
  /// fetching. Reschedules the reminders when a date may have moved.
  Future<void> recompute() async {
    final adjustments = await _advise();
    if (await _db.wateringAdjustmentsDao.replaceAll(adjustments)) {
      await _plantsRepo.rescheduleNotifications();
    }
  }

  /// Forgets every forecast and adjustment (weather turned off).
  Future<void> clear() async {
    await _db.localWeatherRegionsDao.clear();
    if (await _db.wateringAdjustmentsDao.replaceAll(const [])) {
      await _plantsRepo.rescheduleNotifications();
    }
  }

  bool _isDue(LocalWeatherRegionsTableData region, DateTime now) {
    final attempted = region.attemptedAt;
    if (attempted != null &&
        region.lastError != null &&
        now.difference(attempted) < retryInterval) {
      return false;
    }
    final fetched = region.fetchedAt;
    return fetched == null || now.difference(fetched) >= refreshInterval;
  }

  /// Puts every location with coordinates in a region, creating regions
  /// for the ones no region is near, and drops regions no location uses.
  Future<List<LocalWeatherRegionsTableData>> _assignRegions() async {
    final dao = _db.localWeatherRegionsDao;
    final regions = await dao.getAll();
    final used = <String, LocalWeatherRegionsTableData>{};
    for (final location in await _db.locationsDao.getAll()) {
      final lat = location.latitude;
      final lon = location.longitude;
      if (lat == null || lon == null || !shared.isValidCoordinate(lat, lon)) {
        continue;
      }
      var region = nearestRegion(regions, lat, lon);
      if (region == null) {
        region = LocalWeatherRegionsTableData(
          id: const Uuid().v4(),
          latitude: lat,
          longitude: lon,
          daily: '[]',
          previousDaily: '[]',
        );
        await dao.upsert(region.toCompanion(false));
        regions.add(region);
      }
      used[region.id] = region;
    }
    final idle = [for (final r in regions) if (!used.containsKey(r.id)) r.id];
    if (idle.isNotEmpty) await dao.deleteIds(idle);
    return used.values.toList();
  }

  Future<void> _fetch(LocalWeatherRegionsTableData region, DateTime now) async {
    final dao = _db.localWeatherRegionsDao;
    final shared.WeatherForecast forecast;
    try {
      forecast = await _client.fetch(region.latitude, region.longitude);
    } catch (e) {
      await dao.upsert(region
          .copyWith(attemptedAt: Value(now), lastError: Value('$e'))
          .toCompanion(false));
      return;
    }
    final offset = forecast.utcOffset ??
        Duration(seconds: region.utcOffsetSeconds ?? 0);
    final issuedOn = shared.dateKey(now.toUtc().add(offset));
    // Keep the forecast issued on an earlier day: refetching on the same day
    // must not let today's forecast cap itself.
    final lastIssuedOn = region.issuedOn;
    final previousDaily = lastIssuedOn != null &&
            lastIssuedOn.compareTo(issuedOn) < 0
        ? jsonEncode([
            for (final d in _decode(region.daily))
              if (d.date.compareTo(lastIssuedOn) >= 0) d.toJson(),
          ])
        : region.previousDaily;
    await dao.upsert(region
        .copyWith(
          utcOffsetSeconds: Value(offset.inSeconds),
          fetchedAt: Value(now),
          attemptedAt: Value(now),
          lastError: const Value(null),
          issuedOn: Value(issuedOn),
          daily: jsonEncode([for (final d in forecast.daily) d.toJson()]),
          previousDaily: previousDaily,
        )
        .toCompanion(false));
  }

  Future<List<WateringAdjustment>> _advise() async {
    final regions = [
      for (final r in await _db.localWeatherRegionsDao.getAll())
        if (r.fetchedAt != null) r,
    ];
    if (regions.isEmpty) return const [];
    final locations = {
      for (final l in await _db.locationsDao.getAll()) l.id: l,
    };
    final species = {
      for (final s in await SpeciesRepository(_db).getAll()) s.id: s,
    };
    final now = _now();
    final weatherByRegion = <String, _RegionWeather>{};
    final adjustments = <WateringAdjustment>[];
    for (final plant in await _plantsRepo.getAll()) {
      if (!plant.isActive) continue;
      final last = plant.lastIrrigatedAt;
      final frequency = plant.irrigationFrequencyDays ??
          species[plant.speciesId]?.defaultIrrigationFrequencyDays;
      final location = locations[plant.locationId];
      if (last == null || frequency == null || frequency < 1) continue;
      final lat = location?.latitude;
      final lon = location?.longitude;
      if (lat == null || lon == null) continue;
      final region = nearestRegion(regions, lat, lon);
      if (region == null) continue;

      final weather =
          weatherByRegion[region.id] ??= _RegionWeather.of(region, now);
      final result = shared.adviseWatering(
        // The app stores local wall-clock times: the date is as written.
        lastWateredOn: DateTime.utc(last.year, last.month, last.day),
        frequencyDays: frequency,
        exposedToRain: location!.exposedToRain,
        today: weather.today,
        days: weather.days,
        baselineEt0: weather.baselineEt0,
        rules: _rules,
      );
      adjustments.add(WateringAdjustment(
        plantId: plant.id,
        lastWateredAt: last,
        frequencyDays: frequency,
        shiftDays: result.shiftDays,
        reason: WateringAdjustmentReason.parse(result.reason.name),
        rainMm: (result.rainMm * 10).roundToDouble() / 10,
        // The forecast's age, so a device that stops fetching lets its
        // advice expire (WateringAdjustment.maxAge).
        fetchedAt: region.fetchedAt!,
      ));
    }
    return adjustments;
  }

  /// The forecast for a location with coordinates, or null when its region
  /// hasn't been fetched yet.
  static LocationWeather? forLocation(
    List<LocalWeatherRegionsTableData> regions,
    double latitude,
    double longitude,
  ) {
    final region = nearestRegion(
        [for (final r in regions) if (r.fetchedAt != null) r],
        latitude,
        longitude);
    if (region == null) return null;
    return LocationWeather(
      fetchedAt: region.fetchedAt,
      daily: [
        for (final d in _decode(region.daily))
          DailyWeather.fromJson(d.toJson()),
      ],
    );
  }

  /// The region whose center is nearest the point, within
  /// [clusterRadiusKm].
  static LocalWeatherRegionsTableData? nearestRegion(
      Iterable<LocalWeatherRegionsTableData> regions, double lat, double lon) {
    LocalWeatherRegionsTableData? best;
    var bestKm = double.infinity;
    for (final region in regions) {
      final km =
          shared.distanceKm(lat, lon, region.latitude, region.longitude);
      if (km <= clusterRadiusKm && km < bestKm) {
        best = region;
        bestKm = km;
      }
    }
    return best;
  }

  static List<shared.DailyWeather> _decode(String json) => [
        for (final d in jsonDecode(json) as List<dynamic>)
          shared.DailyWeather.fromJson(d as Map<String, dynamic>),
      ];
}

/// One region's days as the advice sees them.
class _RegionWeather {
  _RegionWeather(this.today, this.days, this.baselineEt0);

  factory _RegionWeather.of(LocalWeatherRegionsTableData region, DateTime now) {
    final offset = Duration(seconds: region.utcOffsetSeconds ?? 0);
    final local = now.toUtc().add(offset);
    final today = DateTime.utc(local.year, local.month, local.day);
    final daily = LocalWeatherService._decode(region.daily);
    final days = shared.wateringDays(
      today: today,
      observed: daily,
      forecast: daily,
      previous: LocalWeatherService._decode(region.previousDaily),
    );
    final from = shared.dateKey(
        today.subtract(const Duration(days: shared.baselineEt0Days)));
    final todayKey = shared.dateKey(today);
    final baseline = shared.meanEt0([
          for (final d in daily)
            if (d.date.compareTo(from) >= 0 && d.date.compareTo(todayKey) < 0)
              shared.WeatherDay(et0: d.et0),
        ]) ??
        shared.meanEt0(days.values);
    return _RegionWeather(today, days, baseline);
  }

  final DateTime today;
  final Map<String, shared.WeatherDay> days;
  final double? baselineEt0;
}
