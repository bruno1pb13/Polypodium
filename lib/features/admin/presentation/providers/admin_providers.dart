import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/sync/sync_providers.dart';
import '../../../workspaces/domain/workspace_model.dart';
import '../../../workspaces/presentation/providers/workspace_providers.dart';
import '../../data/admin_client.dart';
import '../../domain/server_data_settings.dart';
import '../../domain/server_status.dart';
import '../../domain/server_user.dart';
import '../../domain/server_watering_settings.dart';
import '../../domain/server_weather_status.dart';

part 'admin_providers.g.dart';

@Riverpod(keepAlive: true)
AdminClient adminClient(Ref ref) => const AdminClient();

@riverpod
Future<ServerStatus> serverStatus(Ref ref, Workspace workspace) {
  final client = ref.watch(adminClientProvider);
  return client.status(
    serverUrl: workspace.serverUrl!,
    token: workspace.token!,
  );
}

@riverpod
class ServerDataSettingsNotifier extends _$ServerDataSettingsNotifier {
  @override
  Future<ServerDataSettings> build(Workspace workspace) {
    final client = ref.watch(adminClientProvider);
    return client.getDataSettings(
      serverUrl: workspace.serverUrl!,
      token: workspace.token!,
    );
  }

  Future<void> setAllowMemberExport(bool allowed) async {
    final settings = await ref.read(adminClientProvider).updateDataSettings(
          serverUrl: workspace.serverUrl!,
          token: workspace.token!,
          allowMemberExport: allowed,
        );
    state = AsyncData(settings);
  }

  Future<void> setAllowMemberImport(bool allowed) async {
    final settings = await ref.read(adminClientProvider).updateDataSettings(
          serverUrl: workspace.serverUrl!,
          token: workspace.token!,
          allowMemberImport: allowed,
        );
    state = AsyncData(settings);
  }

  Future<void> setWeatherEnabled(bool enabled) async {
    final settings = await ref.read(adminClientProvider).updateDataSettings(
          serverUrl: workspace.serverUrl!,
          token: workspace.token!,
          weatherEnabled: enabled,
        );
    state = AsyncData(settings);
    ref.invalidate(serverWeatherStatusProvider(workspace));
  }

  Future<void> setMcpEnabled(bool enabled) async {
    final settings = await ref.read(adminClientProvider).updateDataSettings(
          serverUrl: workspace.serverUrl!,
          token: workspace.token!,
          mcpEnabled: enabled,
        );
    state = AsyncData(settings);
  }
}

@riverpod
Future<ServerWeatherStatus> serverWeatherStatus(Ref ref, Workspace workspace) {
  final client = ref.watch(adminClientProvider);
  return client.weatherStatus(
    serverUrl: workspace.serverUrl!,
    token: workspace.token!,
  );
}

/// The server's weather-adjusted watering rules; null on a server from
/// before them.
@riverpod
class ServerWateringSettingsNotifier extends _$ServerWateringSettingsNotifier {
  @override
  Future<ServerWateringSettings?> build(Workspace workspace) {
    final client = ref.watch(adminClientProvider);
    return client.wateringSettings(
      serverUrl: workspace.serverUrl!,
      token: workspace.token!,
    );
  }

  Future<void> setEnabled(bool enabled) => _update(enabled: enabled);

  Future<void> setRule(WateringRule rule, double value) =>
      _update(rules: {rule: value});

  Future<void> resetRules() =>
      _update(rules: {for (final rule in WateringRule.values) rule: null});

  Future<void> _update(
      {bool? enabled, Map<WateringRule, double?> rules = const {}}) async {
    final settings =
        await ref.read(adminClientProvider).updateWateringSettings(
              serverUrl: workspace.serverUrl!,
              token: workspace.token!,
              enabled: enabled,
              rules: rules,
            );
    state = AsyncData(settings);
    // This device's schedule follows the new rules now instead of on its
    // next hourly refresh, when the admin is looking at the active server.
    final active = ref.read(activeWorkspaceProvider);
    if (active.isLoggedIn && active.serverUrl == workspace.serverUrl) {
      unawaited(ref.read(syncServiceProvider).refreshWateringAdvice());
    }
  }
}

@riverpod
class ServerUsersNotifier extends _$ServerUsersNotifier {
  @override
  Future<List<ServerUser>> build(Workspace workspace) {
    final client = ref.watch(adminClientProvider);
    return client.listUsers(
      serverUrl: workspace.serverUrl!,
      token: workspace.token!,
    );
  }

  Future<void> createUser(String email, String password) async {
    await ref.read(adminClientProvider).createUser(
          serverUrl: workspace.serverUrl!,
          token: workspace.token!,
          email: email,
          password: password,
        );
    ref.invalidateSelf();
  }

  Future<void> setRole(String userId, String role) async {
    await ref.read(adminClientProvider).setRole(
          serverUrl: workspace.serverUrl!,
          token: workspace.token!,
          userId: userId,
          role: role,
        );
    ref.invalidateSelf();
  }

  Future<void> setDisabled(String userId, bool disabled) async {
    await ref.read(adminClientProvider).setDisabled(
          serverUrl: workspace.serverUrl!,
          token: workspace.token!,
          userId: userId,
          disabled: disabled,
        );
    ref.invalidateSelf();
  }
}
