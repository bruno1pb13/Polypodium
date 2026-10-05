import 'package:flutter_test/flutter_test.dart';
import 'package:polypodium/features/workspaces/domain/workspace_model.dart';

void main() {
  test('disconnected clears the session but keeps the server details', () {
    final ws = Workspace(
      id: 'w1',
      name: 'Casa',
      type: WorkspaceType.remote,
      serverUrl: 'https://plantas.example',
      userEmail: 'a@b.c',
      token: 'jwt',
      deviceId: 'dev-1',
      lastSyncAt: DateTime(2026, 10, 1),
      role: 'admin',
      createdAt: DateTime(2026, 1, 1),
    );

    final out = ws.disconnected();

    expect(out.isLoggedIn, isFalse);
    expect(out.token, isNull);
    expect(out.userEmail, isNull);
    expect(out.lastSyncAt, isNull);
    expect(out.role, isNull);
    expect(out.serverUrl, 'https://plantas.example');
    expect(out.deviceId, 'dev-1');
  });

  group('garden', () {
    final ws = Workspace(
      id: 'w1',
      name: 'Horta',
      type: WorkspaceType.remote,
      serverUrl: 'https://plantas.example',
      userEmail: 'a@b.c',
      token: 'jwt',
      deviceId: 'dev-1',
      createdAt: DateTime(2026, 1, 1),
      gardenId: 'g1',
      gardenName: 'Horta',
    );

    test('round-trips through JSON', () {
      final out = Workspace.fromJson(ws.toJson());
      expect(out.gardenId, 'g1');
      expect(out.gardenName, 'Horta');
    });

    test('a workspace saved before gardens targets the personal garden', () {
      final json = ws.toJson()
        ..remove('gardenId')
        ..remove('gardenName');
      final out = Workspace.fromJson(json);
      expect(out.gardenId, isNull);
      expect(out.gardenName, isNull);
    });

    test('survives disconnecting, so reconnecting syncs the same garden', () {
      final out = ws.disconnected();
      expect(out.gardenId, 'g1');
      expect(out.gardenName, 'Horta');
    });

    test('copyWith can clear it', () {
      final out = ws.copyWith(gardenId: null, gardenName: null);
      expect(out.gardenId, isNull);
      expect(out.gardenName, isNull);
      expect(ws.copyWith(name: 'x').gardenId, 'g1');
    });
  });
}
