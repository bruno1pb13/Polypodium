import 'dart:convert';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:polypodium/core/database/app_database.dart';
import 'package:polypodium/core/notifications/notification_service.dart';
import 'package:polypodium/features/plants/domain/plant_model.dart';
import 'package:polypodium/features/reminders/domain/reminder_model.dart';
import 'package:polypodium/features/weather/data/local_weather_service.dart';
import 'package:polypodium/features/weather/data/open_meteo_client.dart';
import 'package:polypodium/features/weather/domain/watering_adjustment.dart';

class _Notifications implements INotificationService {
  int reschedules = 0;

  @override
  Future<void> rescheduleAll(List<PlantWithSpecies> plants,
      {List<PlantReminder> reminders = const []}) async {
    reschedules++;
  }
}

/// Open-Meteo's daily columns from 30 days before [today] to 6 days after,
/// typical (ET0 4 mm) and dry except for [rain] (mm by date, 100% likely).
Map<String, Object?> _openMeteo(DateTime today,
    {Map<String, double> rain = const {}}) {
  final dates = [
    for (var k = -30; k <= 6; k++)
      _key(DateTime.utc(today.year, today.month, today.day + k)),
  ];
  return {
    'timezone': 'America/Sao_Paulo',
    'utc_offset_seconds': -10800,
    'daily': {
      'time': dates,
      'precipitation_sum': [for (final d in dates) rain[d] ?? 0],
      'precipitation_probability_max': [for (final _ in dates) 100],
      'et0_fao_evapotranspiration': [for (final _ in dates) 4],
      'weather_code': [for (final d in dates) rain[d] == null ? 0 : 61],
      'temperature_2m_max': [for (final _ in dates) 25],
      'temperature_2m_min': [for (final _ in dates) 15],
    },
  };
}

String _key(DateTime d) => d.toIso8601String().substring(0, 10);

void main() {
  late AppDatabase db;
  late _Notifications notifications;
  late List<Uri> requests;
  late http.Response Function(Uri) respond;
  // 12:00 in São Paulo (UTC-3).
  var now = DateTime.utc(2026, 10, 20, 15);

  LocalWeatherService service() => LocalWeatherService(
        db,
        client: OpenMeteoClient(
          client: MockClient((request) async {
            requests.add(request.url);
            return respond(request.url);
          }),
        ),
        notifications: notifications,
        now: () => now,
      );

  Future<void> addLocation(String id, double? lat, double? lon,
          {bool exposed = true}) =>
      db.locationsDao.upsert(LocationsTableCompanion.insert(
        id: id,
        name: id,
        latitude: Value(lat),
        longitude: Value(lon),
        exposedToRain: Value(exposed),
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      ));

  Future<void> addPlant(String id, String locationId,
          {DateTime? lastWatered, int frequency = 4}) =>
      db.plantsDao.upsert(PlantsTableCompanion.insert(
        id: id,
        speciesId: 's1',
        nickname: id,
        soilType: 'loamy',
        locationId: Value(locationId),
        irrigationFrequencyDays: Value(frequency),
        lastIrrigatedAt: Value(lastWatered ?? DateTime(2026, 10, 17, 8)),
        acquisitionDate: DateTime(2026, 1, 1),
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      ));

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    notifications = _Notifications();
    requests = [];
    now = DateTime.utc(2026, 10, 20, 15);
    respond = (_) => http.Response(
        jsonEncode(_openMeteo(DateTime.utc(2026, 10, 20),
            rain: {'2026-10-20': 20})),
        200);
    await db.speciesDao.upsert(SpeciesTableCompanion.insert(
      id: 's1',
      scientificName: 'Sci',
      popularName: 'Pop',
      recommendedSoilTypes: const [],
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    ));
    await addLocation('quintal', -23.5505, -46.6333);
    await addLocation('sala', -23.5510, -46.6340, exposed: false);
    await addPlant('fora', 'quintal');
    await addPlant('dentro', 'sala');
  });

  tearDown(() => db.close());

  test('nearby locations share one fetch; rain postpones only exposed plants',
      () async {
    await service().refresh();

    expect(requests, hasLength(1));
    expect(requests.single.queryParameters['latitude'], '-23.5505');
    expect(requests.single.queryParameters.containsKey('hourly'), isFalse);
    expect(await db.localWeatherRegionsDao.getAll(), hasLength(1));

    final adjustments = await db.wateringAdjustmentsDao.getAll();
    expect(adjustments['fora']!.shiftDays, greaterThan(0));
    expect(adjustments['fora']!.reason, WateringAdjustmentReason.rain);
    expect(adjustments['fora']!.rainMm, 20);
    expect(adjustments['fora']!.fetchedAt.isAtSameMomentAs(now), isTrue);
    expect(adjustments['dentro']!.shiftDays, 0);
    expect(notifications.reschedules, 1);
  });

  test('a fetched region is not fetched again within a day', () async {
    await service().refresh();
    now = now.add(const Duration(hours: 23));
    await service().refresh();
    expect(requests, hasLength(1));

    now = now.add(const Duration(hours: 1));
    await service().refresh();
    expect(requests, hasLength(2));
  });

  test('a failed fetch is recorded and retried only after an hour', () async {
    respond = (_) => http.Response('{"error":true,"reason":"busy"}', 429);
    await service().refresh();
    final region = (await db.localWeatherRegionsDao.getAll()).single;
    expect(region.lastError, contains('busy'));
    expect(region.fetchedAt, isNull);
    expect(await db.wateringAdjustmentsDao.getAll(), isEmpty);

    now = now.add(const Duration(minutes: 30));
    await service().refresh();
    expect(requests, hasLength(1));

    now = now.add(const Duration(minutes: 31));
    await service().refresh();
    expect(requests, hasLength(2));
  });

  test('the next day keeps the earlier forecast to cap new rain', () async {
    respond = (_) => http.Response(
        jsonEncode(_openMeteo(DateTime.utc(2026, 10, 20),
            rain: {'2026-10-22': 2})),
        200);
    await service().refresh();
    // Fetched again the same day: still nothing earlier to cap with.
    now = now.add(const Duration(hours: 24, minutes: -1));
    respond = (_) => http.Response(
        jsonEncode(_openMeteo(DateTime.utc(2026, 10, 20),
            rain: {'2026-10-22': 9})),
        200);
    await service().refresh();
    expect(requests, hasLength(1));

    now = DateTime.utc(2026, 10, 21, 15);
    respond = (_) => http.Response(
        jsonEncode(_openMeteo(DateTime.utc(2026, 10, 21),
            rain: {'2026-10-22': 30})),
        200);
    await service().refresh();
    final region = (await db.localWeatherRegionsDao.getAll()).single;
    expect(region.issuedOn, '2026-10-21');
    final previous = jsonDecode(region.previousDaily) as List<dynamic>;
    expect(previous.first['date'], '2026-10-20');
    expect(
        previous.firstWhere((d) => d['date'] == '2026-10-22')
            ['precipitationSum'],
        2);
  });

  test('regions no location uses any more are dropped', () async {
    await service().refresh();
    await addLocation('quintal', null, null);
    await addLocation('sala', null, null);
    await service().refresh();
    expect(await db.localWeatherRegionsDao.getAll(), isEmpty);
    expect(await db.wateringAdjustmentsDao.getAll(), isEmpty);
  });

  test('a far location gets its own region', () async {
    await addLocation('sitio', -22.9068, -43.1729);
    await service().refresh();
    expect(requests, hasLength(2));
    expect(await db.localWeatherRegionsDao.getAll(), hasLength(2));
  });

  test('clear forgets forecasts and adjustments', () async {
    await service().refresh();
    await service().clear();
    expect(await db.localWeatherRegionsDao.getAll(), isEmpty);
    expect(await db.wateringAdjustmentsDao.getAll(), isEmpty);
    expect(notifications.reschedules, 2);
  });

  test('forLocation serves the nearest fetched region', () async {
    await service().refresh();
    final regions = await db.localWeatherRegionsDao.getAll();
    final weather =
        LocalWeatherService.forLocation(regions, -23.5508, -46.6335);
    expect(weather!.fetchedAt!.isAtSameMomentAs(now), isTrue);
    expect(weather.fromDay(DateTime(2026, 10, 20)).first.precipitationSum, 20);
    expect(LocalWeatherService.forLocation(regions, 0, 0), isNull);
  });
}
