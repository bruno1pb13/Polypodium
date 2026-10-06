/// Server-wide toggles for what member (non-admin) accounts may do, plus
/// optional server features, mirrored from `GET/PATCH /api/v1/admin/settings`.
class ServerDataSettings {
  const ServerDataSettings({
    required this.allowMemberExport,
    required this.allowMemberImport,
    this.weatherEnabled,
  });

  final bool allowMemberExport;
  final bool allowMemberImport;

  /// Whether the server fetches weather forecasts for locations with
  /// coordinates. Null when the server predates the feature.
  final bool? weatherEnabled;

  bool get supportsWeather => weatherEnabled != null;

  factory ServerDataSettings.fromJson(Map<String, dynamic> json) =>
      ServerDataSettings(
        allowMemberExport: json['allowMemberExport'] as bool? ?? true,
        allowMemberImport: json['allowMemberImport'] as bool? ?? true,
        weatherEnabled: json['weatherEnabled'] as bool?,
      );
}
