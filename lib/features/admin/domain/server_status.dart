class ServerStatus {
  final int uptimeSeconds;
  final String version;
  final int userCount;

  /// Newest published server release, when the server checked GitHub.
  final String? latestVersion;

  /// Whether this server runs an older version than [latestVersion]. Only
  /// informational: the app never offers to update the server.
  final bool updateAvailable;

  const ServerStatus({
    required this.uptimeSeconds,
    required this.version,
    required this.userCount,
    this.latestVersion,
    this.updateAvailable = false,
  });

  factory ServerStatus.fromJson(Map<String, dynamic> json) => ServerStatus(
        uptimeSeconds: json['uptimeSeconds'] as int,
        version: json['version'] as String,
        userCount: json['userCount'] as int,
        // Servers from before the update check omit both fields.
        latestVersion: json['latestVersion'] as String?,
        updateAvailable: json['updateAvailable'] as bool? ?? false,
      );
}
