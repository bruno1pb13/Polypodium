enum WorkspaceType { local, remote }

/// A device-local or server-backed data space. Each workspace maps to its
/// own isolated Drift database file (see workspace_paths.dart) so that
/// switching workspaces never mixes data between them.
class Workspace {
  final String id;
  final String name;
  final WorkspaceType type;
  final String? serverUrl;
  final String? userEmail;
  final String? token;
  final String? deviceId;
  final DateTime? lastSyncAt;
  final DateTime createdAt;

  /// Server-wide role of the logged-in account ('admin' | 'member'), cached
  /// from the last login/register/me response. Null for the local workspace
  /// or a remote workspace that hasn't authenticated since this field was
  /// introduced.
  final String? role;

  /// Set only for a workspace that inherited pre-existing on-disk storage
  /// from before workspaces existed (see WorkspaceRepository.ensureBootstrapped).
  final String? dbFileNameOverride;

  /// Server garden (jardim) this workspace syncs, sent as the
  /// `X-Polypodium-Garden` header. Null means the account's personal garden,
  /// which is also what servers predating gardens serve.
  final String? gardenId;

  /// Display name of [gardenId] when it was picked, for the workspace list.
  final String? gardenName;

  static const String localId = 'local';

  const Workspace({
    required this.id,
    required this.name,
    required this.type,
    this.serverUrl,
    this.userEmail,
    this.token,
    this.deviceId,
    this.lastSyncAt,
    required this.createdAt,
    this.dbFileNameOverride,
    this.role,
    this.gardenId,
    this.gardenName,
  });

  factory Workspace.newLocal() => Workspace(
        id: localId,
        name: 'Local',
        type: WorkspaceType.local,
        createdAt: DateTime.now(),
      );

  bool get isLoggedIn =>
      type == WorkspaceType.remote && token != null && serverUrl != null;

  bool get isServerAdmin => isLoggedIn && role == 'admin';

  /// Clears session credentials while keeping the server connection details,
  /// mirroring the previous global SyncService.logout() behavior.
  Workspace disconnected() => copyWith(
        token: null,
        userEmail: null,
        lastSyncAt: null,
        role: null,
      );

  Workspace copyWith({
    String? id,
    String? name,
    WorkspaceType? type,
    Object? serverUrl = const _Sentinel(),
    Object? userEmail = const _Sentinel(),
    Object? token = const _Sentinel(),
    Object? deviceId = const _Sentinel(),
    Object? lastSyncAt = const _Sentinel(),
    DateTime? createdAt,
    Object? dbFileNameOverride = const _Sentinel(),
    Object? role = const _Sentinel(),
    Object? gardenId = const _Sentinel(),
    Object? gardenName = const _Sentinel(),
  }) {
    return Workspace(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      serverUrl:
          serverUrl is _Sentinel ? this.serverUrl : serverUrl as String?,
      userEmail:
          userEmail is _Sentinel ? this.userEmail : userEmail as String?,
      token: token is _Sentinel ? this.token : token as String?,
      deviceId: deviceId is _Sentinel ? this.deviceId : deviceId as String?,
      lastSyncAt:
          lastSyncAt is _Sentinel ? this.lastSyncAt : lastSyncAt as DateTime?,
      createdAt: createdAt ?? this.createdAt,
      dbFileNameOverride: dbFileNameOverride is _Sentinel
          ? this.dbFileNameOverride
          : dbFileNameOverride as String?,
      role: role is _Sentinel ? this.role : role as String?,
      gardenId: gardenId is _Sentinel ? this.gardenId : gardenId as String?,
      gardenName:
          gardenName is _Sentinel ? this.gardenName : gardenName as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type.name,
        'serverUrl': serverUrl,
        'userEmail': userEmail,
        'token': token,
        'deviceId': deviceId,
        'lastSyncAt': lastSyncAt?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'dbFileNameOverride': dbFileNameOverride,
        'role': role,
        'gardenId': gardenId,
        'gardenName': gardenName,
      };

  factory Workspace.fromJson(Map<String, dynamic> json) => Workspace(
        id: json['id'] as String,
        name: json['name'] as String,
        type: WorkspaceType.values.byName(json['type'] as String),
        serverUrl: json['serverUrl'] as String?,
        userEmail: json['userEmail'] as String?,
        token: json['token'] as String?,
        deviceId: json['deviceId'] as String?,
        lastSyncAt: json['lastSyncAt'] != null
            ? DateTime.tryParse(json['lastSyncAt'] as String)
            : null,
        createdAt: DateTime.parse(json['createdAt'] as String),
        dbFileNameOverride: json['dbFileNameOverride'] as String?,
        role: json['role'] as String?,
        gardenId: json['gardenId'] as String?,
        gardenName: json['gardenName'] as String?,
      );
}

/// Marks an unset copyWith argument, distinct from an explicit null.
class _Sentinel {
  const _Sentinel();
}
