import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:polypodium/features/admin/data/admin_client.dart';
import 'package:polypodium/features/admin/domain/server_status.dart';
import 'package:polypodium/features/admin/presentation/providers/admin_providers.dart';
import 'package:polypodium/features/admin/presentation/providers/server_update_notice.dart';
import 'package:polypodium/features/workspaces/domain/workspace_model.dart';
import 'package:polypodium/features/workspaces/presentation/providers/workspace_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockAdminClient extends Mock implements AdminClient {}

Workspace _remote({String role = 'admin'}) => Workspace(
      id: 'ws-1',
      name: 'Casa',
      type: WorkspaceType.remote,
      serverUrl: 'https://plants.example',
      token: 't',
      role: role,
      createdAt: DateTime(2026),
    );

ServerStatus _status({
  String version = '2.8.0-3-gabc1234',
  String? latest = '2.9.0',
  bool updateAvailable = true,
}) =>
    ServerStatus(
      uptimeSeconds: 1,
      version: version,
      userCount: 1,
      latestVersion: latest,
      updateAvailable: updateAvailable,
    );

void main() {
  late _MockAdminClient client;

  ProviderContainer containerFor(Workspace workspace) {
    final container = ProviderContainer(overrides: [
      adminClientProvider.overrideWithValue(client),
      activeWorkspaceProvider.overrideWithValue(workspace),
    ]);
    addTearDown(container.dispose);
    return container;
  }

  void serverAnswers(ServerStatus status) {
    when(() => client.status(
          serverUrl: any(named: 'serverUrl'),
          token: any(named: 'token'),
        )).thenAnswer((_) async => status);
  }

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    client = _MockAdminClient();
  });

  test('tells an admin the server is behind, with readable versions',
      () async {
    serverAnswers(_status());
    final container = containerFor(_remote());

    await container.read(serverUpdateNoticeProvider.notifier).refresh();

    final notice = container.read(serverUpdateNoticeProvider)!;
    expect(notice.currentVersion, '2.8.0');
    expect(notice.latestVersion, '2.9.0');
    expect(notice.serverUrl, 'https://plants.example');
  });

  test('says nothing when the server is up to date', () async {
    serverAnswers(_status(version: '2.9.0', updateAvailable: false));
    final container = containerFor(_remote());

    await container.read(serverUpdateNoticeProvider.notifier).refresh();
    expect(container.read(serverUpdateNoticeProvider), isNull);
  });

  test('members and local workspaces never ask the server', () async {
    serverAnswers(_status());
    for (final workspace in [_remote(role: 'member'), Workspace.newLocal()]) {
      final container = containerFor(workspace);
      await container.read(serverUpdateNoticeProvider.notifier).refresh();
      expect(container.read(serverUpdateNoticeProvider), isNull);
    }
    verifyNever(() => client.status(
          serverUrl: any(named: 'serverUrl'),
          token: any(named: 'token'),
        ));
  });

  test('a hidden notice stays hidden until a newer release', () async {
    serverAnswers(_status());
    final container = containerFor(_remote());
    final notifier = container.read(serverUpdateNoticeProvider.notifier);

    await notifier.refresh();
    await notifier.dismiss();
    expect(container.read(serverUpdateNoticeProvider), isNull);

    await notifier.refresh();
    expect(container.read(serverUpdateNoticeProvider), isNull);

    serverAnswers(_status(latest: '2.10.0'));
    await notifier.refresh();
    expect(container.read(serverUpdateNoticeProvider)!.latestVersion, '2.10.0');
  });

  test('an unreachable server keeps quiet', () async {
    when(() => client.status(
          serverUrl: any(named: 'serverUrl'),
          token: any(named: 'token'),
        )).thenThrow(Exception('offline'));
    final container = containerFor(_remote());

    await container.read(serverUpdateNoticeProvider.notifier).refresh();
    expect(container.read(serverUpdateNoticeProvider), isNull);
  });

  test('servers from before the update check report nothing', () {
    final status = ServerStatus.fromJson(
        {'uptimeSeconds': 5, 'version': '1.0.0', 'userCount': 2});
    expect(status.latestVersion, isNull);
    expect(status.updateAvailable, isFalse);
  });
}
