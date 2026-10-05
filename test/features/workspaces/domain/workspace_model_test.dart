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
}
