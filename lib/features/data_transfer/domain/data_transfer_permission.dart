/// Why export/import is denied. The UI maps each code to a localized
/// message.
enum DataTransferDeniedReason {
  notConnected,
  disabledByAdmin,
  permissionUnverified,
}

/// Whether the active workspace may export/import data, and why not when
/// denied. Local workspaces are always allowed; remote workspaces follow the
/// server's member permissions (admins are never restricted).
class DataTransferPermission {
  const DataTransferPermission({
    required this.canExport,
    required this.canImport,
    this.deniedReason,
  });

  static const allowed =
      DataTransferPermission(canExport: true, canImport: true);

  final bool canExport;
  final bool canImport;

  /// Shown under a disabled action when [canExport]/[canImport] is false.
  final DataTransferDeniedReason? deniedReason;
}
