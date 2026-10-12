import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:polypodium/features/workspaces/data/workspace_disk_usage.dart';
import 'package:polypodium/features/workspaces/domain/workspace_model.dart';

void main() {
  late Directory docs;

  setUp(() => docs = Directory.systemTemp.createTempSync('disk_usage'));
  tearDown(() => docs.deleteSync(recursive: true));

  void write(String path, int bytes) => (File(p.join(docs.path, path))
        ..createSync(recursive: true))
      .writeAsBytesSync(List.filled(bytes, 0));

  final workspace = Workspace(
    id: 'ws1',
    name: 'Server',
    type: WorkspaceType.remote,
    createdAt: DateTime(2026, 1, 1),
  );

  test('sums the database with its side files, and the photos folder',
      () async {
    write('workspace_ws1.db', 100);
    write('workspace_ws1.db-wal', 20);
    write('workspace_photos/ws1/a.jpg', 1000);
    write('workspace_photos/ws1/sub/b.jpg', 500);
    // Another workspace's files don't count.
    write('workspace_ws2.db', 7);
    write('workspace_photos/ws2/c.jpg', 9);

    final usage = await measureDiskUsage(workspace, docs.path);

    expect(usage.database, 120);
    expect(usage.photos, 1500);
    expect(usage.total, 1620);
  });

  test('a workspace with nothing on disk takes nothing', () async {
    final usage = await measureDiskUsage(workspace, docs.path);
    expect(usage.total, 0);
  });
}
