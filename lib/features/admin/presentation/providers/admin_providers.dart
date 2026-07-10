import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../workspaces/domain/workspace_model.dart';
import '../../data/admin_client.dart';
import '../../domain/server_data_settings.dart';
import '../../domain/server_status.dart';
import '../../domain/server_user.dart';

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
