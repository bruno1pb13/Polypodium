/// An update the user can install.
class AvailableUpdate {
  /// Stable identifier, used to remember an update the user dismissed.
  final String id;

  /// Version name to show (e.g. `1.2.0`), when the source tells it. Google
  /// Play only reports a version code.
  final String? version;

  /// Where to download it, for updates that don't come from a store.
  final Uri? downloadUrl;

  const AvailableUpdate({required this.id, this.version, this.downloadUrl});
}

/// Looks for updates in the place this copy of the app came from.
abstract interface class UpdateChecker {
  /// The newer version on offer, or null when the app is up to date.
  /// Throws when the source can't be reached.
  Future<AvailableUpdate?> check();

  /// Starts installing [update]: opens the store flow or the download.
  Future<void> install(AvailableUpdate update);
}
