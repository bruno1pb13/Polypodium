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
  final int cursor;
  final DateTime? lastSyncAt;
  final DateTime createdAt;

  /// Set only for a workspace that inherited pre-existing on-disk storage
  /// from before workspaces existed (see WorkspaceRepository.ensureBootstrapped).
  final String? dbFileNameOverride;

  static const String localId = 'local';

  const Workspace({
    required this.id,
    required this.name,
    required this.type,
    this.serverUrl,
    this.userEmail,
    this.token,
    this.deviceId,
    this.cursor = 0,
    this.lastSyncAt,
    required this.createdAt,
    this.dbFileNameOverride,
  });

  factory Workspace.newLocal() => Workspace(
        id: localId,
        name: 'Local',
        type: WorkspaceType.local,
        createdAt: DateTime.now(),
      );

  bool get isLoggedIn =>
      type == WorkspaceType.remote && token != null && serverUrl != null;

  /// Clears session credentials while keeping the server connection details,
  /// mirroring the previous global SyncService.logout() behavior.
  Workspace disconnected() => copyWith(
        token: const _Sentinel(),
        userEmail: const _Sentinel(),
        lastSyncAt: const _Sentinel(),
        cursor: 0,
      );

  Workspace copyWith({
    String? id,
    String? name,
    WorkspaceType? type,
    Object? serverUrl = const _Sentinel(),
    Object? userEmail = const _Sentinel(),
    Object? token = const _Sentinel(),
    Object? deviceId = const _Sentinel(),
    int? cursor,
    Object? lastSyncAt = const _Sentinel(),
    DateTime? createdAt,
    Object? dbFileNameOverride = const _Sentinel(),
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
      cursor: cursor ?? this.cursor,
      lastSyncAt:
          lastSyncAt is _Sentinel ? this.lastSyncAt : lastSyncAt as DateTime?,
      createdAt: createdAt ?? this.createdAt,
      dbFileNameOverride: dbFileNameOverride is _Sentinel
          ? this.dbFileNameOverride
          : dbFileNameOverride as String?,
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
        'cursor': cursor,
        'lastSyncAt': lastSyncAt?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'dbFileNameOverride': dbFileNameOverride,
      };

  factory Workspace.fromJson(Map<String, dynamic> json) => Workspace(
        id: json['id'] as String,
        name: json['name'] as String,
        type: WorkspaceType.values.byName(json['type'] as String),
        serverUrl: json['serverUrl'] as String?,
        userEmail: json['userEmail'] as String?,
        token: json['token'] as String?,
        deviceId: json['deviceId'] as String?,
        cursor: json['cursor'] as int? ?? 0,
        lastSyncAt: json['lastSyncAt'] != null
            ? DateTime.tryParse(json['lastSyncAt'] as String)
            : null,
        createdAt: DateTime.parse(json['createdAt'] as String),
        dbFileNameOverride: json['dbFileNameOverride'] as String?,
      );
}

/// Marks an unset copyWith argument, distinct from an explicit null.
class _Sentinel {
  const _Sentinel();
}
