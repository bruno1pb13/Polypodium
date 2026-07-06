import 'workspace_model.dart';

const legacyDbFileName = 'polypodium.db';
const _legacyPhotosDirName = 'plant_photos';

/// The Drift database file for [ws]. Workspaces that inherited pre-existing
/// on-disk storage (see WorkspaceRepository.ensureBootstrapped) keep pointing
/// at that file via dbFileNameOverride; every other workspace gets its own
/// dedicated file so data never mixes between workspaces.
String dbFileNameFor(Workspace ws) =>
    ws.dbFileNameOverride ?? 'workspace_${ws.id}.db';

/// The photos directory for [ws], tied to the same override used for the
/// database file so a migrated workspace's photos and rows stay together.
String photoDirNameFor(Workspace ws) => ws.dbFileNameOverride == legacyDbFileName
    ? _legacyPhotosDirName
    : 'workspace_photos/${ws.id}';
