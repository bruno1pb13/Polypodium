import 'package:drift/drift.dart';

/// Forecasts this device fetches itself from Open-Meteo for the local
/// workspace (a workspace with a server takes them from the server). Local
/// to the device and never synced. Nearby locations share one region, whose
/// center is the first coordinate that created it and never moves.
class LocalWeatherRegionsTable extends Table {
  @override
  String get tableName => 'local_weather_regions';

  TextColumn get id => text()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();

  /// The region's offset from UTC at the last fetch, for its local date.
  IntColumn get utcOffsetSeconds => integer().nullable()();
  DateTimeColumn get fetchedAt => dateTime().nullable()();
  DateTimeColumn get attemptedAt => dateTime().nullable()();
  TextColumn get lastError => text().nullable()();

  /// The region's local date (`YYYY-MM-DD`) when [daily] was issued.
  TextColumn get issuedOn => text().nullable()();

  /// The last fetch's daily rows as JSON: observed past days, then the
  /// forecast from [issuedOn] on.
  TextColumn get daily => text().withDefault(const Constant('[]'))();

  /// The forecast (from its own issue date on) of the last fetch issued on
  /// an earlier day than [daily], which caps forecast rain (see
  /// `wateringDays`).
  TextColumn get previousDaily => text().withDefault(const Constant('[]'))();

  @override
  Set<Column> get primaryKey => {id};
}
