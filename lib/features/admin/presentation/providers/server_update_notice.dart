import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../workspaces/presentation/providers/workspace_providers.dart';
import 'admin_providers.dart';

part 'server_update_notice.g.dart';

/// A newer server release that the admin hasn't hidden yet.
class ServerUpdateNoticeState {
  const ServerUpdateNoticeState({
    required this.serverUrl,
    required this.currentVersion,
    required this.latestVersion,
  });

  final String serverUrl;

  /// Running version as the server reports it; a main build's `git
  /// describe` suffix (`2.8.0-3-gabc1234`) is trimmed for display.
  final String currentVersion;
  final String latestVersion;
}

/// Tells admins of the active workspace's server that it is behind the
/// newest release. Only a notice: updating the server is done outside the
/// app. Refreshed whenever the app opens or resumes and when the active
/// workspace changes; failures (offline, old server) stay silent.
@Riverpod(keepAlive: true)
class ServerUpdateNotice extends _$ServerUpdateNotice {
  static const _dismissedPrefix = 'serverUpdate.dismissed.';

  @override
  ServerUpdateNoticeState? build() {
    ref.listen(activeWorkspaceProvider, (previous, next) {
      if (previous?.id == next.id) return;
      state = null;
      refresh();
    });
    return null;
  }

  Future<void> refresh() async {
    final workspace = ref.read(activeWorkspaceProvider);
    if (!workspace.isServerAdmin) {
      state = null;
      return;
    }
    try {
      final status = await ref.read(adminClientProvider).status(
            serverUrl: workspace.serverUrl!,
            token: workspace.token!,
          );
      final prefs = await SharedPreferences.getInstance();
      // The workspace may have been switched while the request ran.
      if (ref.read(activeWorkspaceProvider).id != workspace.id) return;

      final latest = status.latestVersion;
      if (!status.updateAvailable ||
          latest == null ||
          prefs.getString('$_dismissedPrefix${workspace.serverUrl}') ==
              latest) {
        state = null;
        return;
      }
      state = ServerUpdateNoticeState(
        serverUrl: workspace.serverUrl!,
        currentVersion: status.version.split('-').first,
        latestVersion: latest,
      );
    } catch (_) {
      // Offline or unreachable: the notice simply waits for the next try.
    }
  }

  /// Hides the notice until the server falls behind a newer release.
  Future<void> dismiss() async {
    final notice = state;
    if (notice == null) return;
    state = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        '$_dismissedPrefix${notice.serverUrl}', notice.latestVersion);
  }
}
