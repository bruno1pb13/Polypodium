import 'dart:async';

import 'package:drift/drift.dart' show TableUpdateQuery;
import 'package:flutter_riverpod/flutter_riverpod.dart' show StreamProvider;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/notifications/notification_provider.dart';
import '../../../admin/presentation/providers/admin_providers.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../../../workspaces/domain/workspace_model.dart';
import '../../../workspaces/presentation/providers/workspace_providers.dart';
import '../../data/local_weather_service.dart';
import '../../data/weather_client.dart';
import '../../domain/location_weather.dart';
import '../../domain/watering_adjustment.dart';

part 'weather_providers.g.dart';

@Riverpod(keepAlive: true)
WeatherClient weatherClient(Ref ref) => const WeatherClient();

/// Whether the active workspace's server serves weather forecasts. False
/// for the local workspace, a disconnected one, or an unreachable server.
@riverpod
Future<bool> serverWeatherEnabled(Ref ref) async {
  final workspace = ref.watch(activeWorkspaceProvider);
  if (!workspace.isLoggedIn) return false;
  try {
    final info = await ref.watch(adminClientProvider).me(
          serverUrl: workspace.serverUrl!,
          token: workspace.token!,
        );
    return info.weatherEnabled;
  } catch (_) {
    return false;
  }
}

/// The forecast for a location, or null when there is none. Errors count
/// as none: weather is extra information and never blocks the list. The
/// local workspace reads what this device fetched itself; any other takes
/// it from its server.
@riverpod
Future<LocationWeather?> locationWeather(Ref ref, String locationId) async {
  final workspace = ref.watch(activeWorkspaceProvider);
  if (workspace.type == WorkspaceType.local) {
    if (!ref.watch(localWeatherEnabledNotifierProvider)) return null;
    final regions = await ref.watch(localWeatherRegionsProvider.future);
    final location =
        await ref.watch(appDatabaseProvider).locationsDao.getById(locationId);
    final lat = location?.latitude;
    final lon = location?.longitude;
    if (lat == null || lon == null) return null;
    return LocalWeatherService.forLocation(regions, lat, lon);
  }
  if (!await ref.watch(serverWeatherEnabledProvider.future)) return null;
  try {
    return await ref.watch(weatherClientProvider).forLocation(
          serverUrl: workspace.serverUrl!,
          token: workspace.token!,
          gardenId: workspace.gardenId,
          locationId: locationId,
        );
  } catch (_) {
    return null;
  }
}

/// The weather adjustments stored on this device, by plant id (see
/// WateringAdjustment): from the server after each sync, or computed here
/// for the local workspace.
@riverpod
Stream<Map<String, WateringAdjustment>> wateringAdjustments(Ref ref) =>
    ref.watch(appDatabaseProvider).wateringAdjustmentsDao.watchAll();

/// The "Previsão do tempo" setting of the local workspace (see
/// SettingsRepository.isLocalWeatherEnabled).
@riverpod
class LocalWeatherEnabledNotifier extends _$LocalWeatherEnabledNotifier {
  @override
  bool build() =>
      ref.watch(settingsRepositoryProvider).isLocalWeatherEnabled();

  Future<void> setEnabled(bool enabled) async {
    await ref.read(settingsRepositoryProvider).setLocalWeatherEnabled(enabled);
    state = enabled;
    if (!enabled &&
        ref.read(activeWorkspaceProvider).type == WorkspaceType.local) {
      await ref.read(localWeatherServiceProvider).clear();
    }
  }
}

/// Whether this device computes the weather itself: only for the local
/// workspace, with the setting on. A workspace with a server never does.
@riverpod
bool localWeatherActive(Ref ref) =>
    ref.watch(activeWorkspaceProvider).type == WorkspaceType.local &&
    ref.watch(localWeatherEnabledNotifierProvider);

@riverpod
LocalWeatherService localWeatherService(Ref ref) => LocalWeatherService(
      ref.watch(appDatabaseProvider),
      notifications: ref.watch(notificationServiceProvider),
    );

/// Written by hand: riverpod_generator can't see the row class drift
/// generates.
final localWeatherRegionsProvider =
    StreamProvider<List<LocalWeatherRegionsTableData>>((ref) =>
        ref.watch(appDatabaseProvider).localWeatherRegionsDao.watchAll());

/// Keeps the local workspace's weather current while the app is open: on
/// start, hourly, and shortly after plants, species or locations change
/// (a watering, a new interval, new coordinates). Each run only fetches
/// the regions that are due, so most of them just recompute the advice.
@Riverpod(keepAlive: true)
class LocalWeatherController extends _$LocalWeatherController {
  StreamSubscription<void>? _changes;
  Timer? _ticker;
  Timer? _debounce;
  Future<void>? _running;
  bool _rerun = false;

  @override
  void build() {
    ref.onDispose(() {
      _changes?.cancel();
      _ticker?.cancel();
      _debounce?.cancel();
    });
    if (!ref.watch(localWeatherActiveProvider)) return;

    final db = ref.watch(appDatabaseProvider);
    _changes = db
        .tableUpdates(TableUpdateQuery.onAllTables(
            [db.plantsTable, db.speciesTable, db.locationsTable]))
        .listen((_) {
      _debounce?.cancel();
      _debounce = Timer(const Duration(seconds: 2), refresh);
    });
    _ticker = Timer.periodic(const Duration(hours: 1), (_) => refresh());
    Future.microtask(refresh);
  }

  /// One run at a time: a call during a run gets one more run after it.
  Future<void> refresh() {
    if (!ref.read(localWeatherActiveProvider)) return Future.value();
    final running = _running;
    if (running != null) {
      _rerun = true;
      return running;
    }
    return _running = _refreshUntilSettled().whenComplete(() => _running = null);
  }

  Future<void> _refreshUntilSettled() async {
    do {
      _rerun = false;
      try {
        await ref.read(localWeatherServiceProvider).refresh();
      } catch (e) {
        // ignore: avoid_print
        print('[LocalWeather] not refreshed: $e');
      }
    } while (_rerun && ref.read(localWeatherActiveProvider));
  }
}
