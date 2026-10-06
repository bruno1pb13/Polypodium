import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../admin/presentation/providers/admin_providers.dart';
import '../../../workspaces/presentation/providers/workspace_providers.dart';
import '../../data/weather_client.dart';
import '../../domain/location_weather.dart';

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

/// The server's forecast for a location, or null when there is none. Errors
/// count as none: weather is extra information and never blocks the list.
@riverpod
Future<LocationWeather?> locationWeather(Ref ref, String locationId) async {
  if (!await ref.watch(serverWeatherEnabledProvider.future)) return null;
  final workspace = ref.watch(activeWorkspaceProvider);
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
