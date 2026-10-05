import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:polypodium/features/settings/presentation/providers/settings_providers.dart';
import 'package:polypodium/features/workspaces/domain/garden.dart';
import 'package:polypodium/features/workspaces/domain/workspace_model.dart';
import 'package:polypodium/features/workspaces/presentation/providers/workspace_providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'workspaces_v1': jsonEncode([Workspace.newLocal().toJson()]),
    });
    final prefs = await SharedPreferences.getInstance();
    container = ProviderContainer(overrides: [
      sharedPreferencesProvider.overrideWith((ref) async => prefs),
    ]);
    addTearDown(container.dispose);
    await container.read(sharedPreferencesProvider.future);
  });

  WorkspacesNotifier notifier() =>
      container.read(workspacesNotifierProvider.notifier);

  /// A server where login succeeds and `/gardens` answers [gardens], or 404
  /// (a server predating gardens) when null.
  MockClient server(List<Map<String, dynamic>>? gardens) =>
      MockClient((request) async {
        if (request.url.path == '/api/v1/auth/login') {
          return http.Response(
              jsonEncode({
                'token': 'tok',
                'userId': 'u1',
                'deviceId': 'dev-1',
                'role': 'member',
              }),
              200);
        }
        if (request.url.path == '/api/v1/gardens' && gardens != null) {
          return http.Response(jsonEncode({'gardens': gardens}), 200);
        }
        return http.Response('Route not found', 404);
      });

  const personal = {
    'id': 'u1',
    'name': '',
    'personal': true,
    'role': 'owner',
    'ownerEmail': 'eu@x.com',
  };
  const shared = {
    'id': 'g1',
    'name': 'Horta',
    'personal': false,
    'role': 'member',
    'ownerEmail': 'ela@x.com',
  };

  Future<Workspace> login(
          MockClient mock, Future<GardenChoice?> Function(List<Garden>) pick) =>
      http.runWithClient(
        () => notifier().createAndLoginRemote(
          serverUrl: 'https://plantas.example',
          email: 'eu@x.com',
          password: 'password1',
          pickGarden: pick,
        ),
        () => mock,
      );

  test('an account in shared gardens picks which one the workspace syncs',
      () async {
    List<Garden>? offered;
    final ws = await login(server([personal, shared]), (gardens) async {
      offered = gardens;
      return (id: 'g1', name: 'Horta');
    });

    expect(offered!.map((g) => g.id), ['u1', 'g1']);
    expect(ws.gardenId, 'g1');
    expect(ws.gardenName, 'Horta');
    expect(ws.name, 'Horta');
  });

  test(
      'only a personal garden, or a server predating gardens, means no '
      'garden and no question', () async {
    for (final mock in [
      server([personal]),
      server(null)
    ]) {
      final ws = await login(mock, (_) async => fail('must not ask'));
      expect(ws.gardenId, isNull);
      expect(ws.name, 'https://plantas.example');
    }
  });

  test(
      'another garden opens in its own workspace, reusing the session, '
      'and is not duplicated', () async {
    final from = await login(server([personal]), (_) async => null);

    final opened =
        await notifier().openGardenWorkspace(from, (id: 'g1', name: 'Horta'));
    expect(opened.id, isNot(from.id));
    expect(opened.gardenId, 'g1');
    expect(opened.token, from.token);
    expect(opened.deviceId, from.deviceId);
    expect(container.read(activeWorkspaceIdNotifierProvider), opened.id);

    final again =
        await notifier().openGardenWorkspace(from, (id: 'g1', name: 'Horta'));
    expect(again.id, opened.id);
    expect(
        container
            .read(workspacesNotifierProvider)
            .where((w) => w.gardenId == 'g1'),
        hasLength(1));

    // The personal garden maps back to the original workspace.
    expect((await notifier().openGardenWorkspace(opened, null)).id, from.id);
  });
}
