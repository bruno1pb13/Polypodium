/// Server-wide toggles for what member (non-admin) accounts may do,
/// mirrored from `GET/PATCH /api/v1/admin/settings`.
class ServerDataSettings {
  const ServerDataSettings({
    required this.allowMemberExport,
    required this.allowMemberImport,
  });

  final bool allowMemberExport;
  final bool allowMemberImport;

  factory ServerDataSettings.fromJson(Map<String, dynamic> json) =>
      ServerDataSettings(
        allowMemberExport: json['allowMemberExport'] as bool? ?? true,
        allowMemberImport: json['allowMemberImport'] as bool? ?? true,
      );
}
