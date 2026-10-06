/// Response of `GET /api/v1/admin/me`: the account's server-wide role plus
/// its effective data-transfer permissions (admins are always allowed;
/// members follow the server's settings).
class AccountInfo {
  const AccountInfo({
    required this.role,
    required this.canExportData,
    required this.canImportData,
    this.weatherEnabled = false,
  });

  final String role;
  final bool canExportData;
  final bool canImportData;

  /// Whether the server serves weather forecasts for locations.
  final bool weatherEnabled;

  bool get isAdmin => role == 'admin';

  factory AccountInfo.fromJson(Map<String, dynamic> json) => AccountInfo(
        role: json['role'] as String,
        // Servers from before these settings existed omit the fields; treat
        // absence as allowed, matching their unrestricted behavior.
        canExportData: json['canExportData'] as bool? ?? true,
        canImportData: json['canImportData'] as bool? ?? true,
        weatherEnabled: json['weatherEnabled'] as bool? ?? false,
      );
}
