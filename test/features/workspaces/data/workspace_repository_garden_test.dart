import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:polypodium/features/workspaces/data/workspace_repository.dart';
import 'package:polypodium/features/workspaces/domain/workspace_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('saveAll/loadAll keep each workspace\'s garden', () async {
    SharedPreferences.setMockInitialValues({});
    final repo = WorkspaceRepository(await SharedPreferences.getInstance());
    final created = DateTime(2026, 1, 1);

    await repo.saveAll([
      Workspace.newLocal(),
      Workspace(
        id: 'personal',
        name: 'https://plantas.example',
        type: WorkspaceType.remote,
        serverUrl: 'https://plantas.example',
        token: 't',
        createdAt: created,
      ),
      Workspace(
        id: 'shared',
        name: 'Horta',
        type: WorkspaceType.remote,
        serverUrl: 'https://plantas.example',
        token: 't',
        createdAt: created,
        gardenId: 'g1',
        gardenName: 'Horta',
      ),
    ]);

    final loaded = {for (final w in repo.loadAll()) w.id: w};
    expect(loaded['personal']!.gardenId, isNull);
    expect(loaded['shared']!.gardenId, 'g1');
    expect(loaded['shared']!.gardenName, 'Horta');
  });
}
