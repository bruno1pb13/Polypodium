/// Response of `GET /api/v1/admin/me`: the account's server-wide role plus
/// its effective data-transfer permissions (admins are always allowed;
/// members follow the server's settings).
class AccountInfo {
  const AccountInfo({
    required this.role,
    required this.canExportData,
    required this.canImportData,
  });

  final String role;
  final bool canExportData;
  final bool canImportData;

  bool get isAdmin => role == 'admin';

  factory AccountInfo.fromJson(Map<String, dynamic> json) => AccountInfo(
        role: json['role'] as String,
        // Servers from before these settings existed omit the fields; treat
        // absence as allowed, matching their unrestricted behavior.
        canExportData: json['canExportData'] as bool? ?? true,
        canImportData: json['canImportData'] as bool? ?? true,
      );
}
