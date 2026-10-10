import 'package:in_app_update/in_app_update.dart';

import 'update_checker.dart';

/// Google Play builds: asks Play for a newer version and installs it with
/// the in-app update flow. Only works on copies installed by Play.
class PlayStoreUpdateChecker implements UpdateChecker {
  const PlayStoreUpdateChecker();

  @override
  Future<AvailableUpdate?> check() async {
    final info = await InAppUpdate.checkForUpdate();
    if (info.updateAvailability != UpdateAvailability.updateAvailable) {
      return null;
    }
    return AvailableUpdate(id: 'play-${info.availableVersionCode}');
  }

  @override
  Future<void> install(AvailableUpdate update) async {
    // Play requires a fresh check right before starting either flow.
    final info = await InAppUpdate.checkForUpdate();
    if (info.immediateUpdateAllowed) {
      await InAppUpdate.performImmediateUpdate();
    } else if (info.flexibleUpdateAllowed) {
      final result = await InAppUpdate.startFlexibleUpdate();
      if (result == AppUpdateResult.success) {
        await InAppUpdate.completeFlexibleUpdate();
      }
    }
  }
}
