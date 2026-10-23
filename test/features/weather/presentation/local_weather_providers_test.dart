import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:polypodium/features/settings/presentation/providers/settings_providers.dart';
import 'package:polypodium/features/weather/presentation/providers/weather_providers.dart';
import 'package:polypodium/features/workspaces/domain/workspace_model.dart';
import 'package:polypodium/features/workspaces/presentation/providers/workspace_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final remote = Workspace(
    id: 'r',
    name: 'Servidor',
    type: WorkspaceType.remote,
    serverUrl: 'https://example.test',
    token: 't',
    createdAt: DateTime(2026, 1, 1),
  );

  Future<ProviderContainer> container(Workspace workspace,
      {required bool enabled}) async {
    SharedPreferences.setMockInitialValues({'local_weather_enabled': enabled});
    final c = ProviderContainer(overrides: [
      activeWorkspaceProvider.overrideWithValue(workspace),
    ]);
    addTearDown(c.dispose);
    await c.read(sharedPreferencesProvider.future);
    return c;
  }

  test('the local workspace computes the weather once turned on', () async {
    final c = await container(Workspace.newLocal(), enabled: true);
    expect(c.read(localWeatherActiveProvider), isTrue);
  });

  test('the local weather starts off', () async {
    SharedPreferences.setMockInitialValues({});
    final c = ProviderContainer(overrides: [
      activeWorkspaceProvider.overrideWithValue(Workspace.newLocal()),
    ]);
    addTearDown(c.dispose);
    await c.read(sharedPreferencesProvider.future);
    expect(c.read(localWeatherActiveProvider), isFalse);
  });

  test('a workspace with a server never computes it, even turned on',
      () async {
    final c = await container(remote, enabled: true);
    expect(c.read(localWeatherActiveProvider), isFalse);
  });
}
