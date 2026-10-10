import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kReleaseMode;

/// Where this copy of the app was installed from, which decides how it may
/// look for updates. Store builds must only ever point at their store: both
/// Google Play and the Microsoft Store forbid the apps they distribute from
/// updating any other way.
enum DistributionChannel {
  /// AAB published on Google Play: updates through the Play in-app update API.
  playStore,

  /// MSIX installed from the Microsoft Store, which updates it by itself.
  msStore,

  /// APK, Windows portable ZIP or AppImage from a GitHub release.
  github,

  /// Debug runs, local builds and anything a package manager keeps up to
  /// date (Flatpak, Snap, distro packages): no update check.
  none,
}

/// Set by the release workflow on Android builds, where the APK and the AAB
/// come from the same code: `--dart-define=DIST_CHANNEL=play|github`.
const _buildChannel = String.fromEnvironment('DIST_CHANNEL');

DistributionChannel detectDistributionChannel() => resolveDistributionChannel(
      operatingSystem: Platform.operatingSystem,
      buildChannel: _buildChannel,
      executablePath: Platform.resolvedExecutable,
      environment: Platform.environment,
      isRelease: kReleaseMode,
    );

/// [detectDistributionChannel] with every input spelled out, for tests.
DistributionChannel resolveDistributionChannel({
  required String operatingSystem,
  required String buildChannel,
  required String executablePath,
  required Map<String, String> environment,
  required bool isRelease,
}) {
  if (!isRelease) return DistributionChannel.none;
  switch (operatingSystem) {
    case 'android':
      // No define means a local build: never guess, an AAB that wrongly
      // pointed at GitHub would break the Play policy.
      return switch (buildChannel) {
        'play' => DistributionChannel.playStore,
        'github' => DistributionChannel.github,
        _ => DistributionChannel.none,
      };
    case 'windows':
      // The MSIX and the portable ZIP share one build, so tell them apart at
      // runtime: packaged apps always run from a WindowsApps folder.
      return executablePath.toLowerCase().contains(r'\windowsapps\')
          ? DistributionChannel.msStore
          : DistributionChannel.github;
    case 'linux':
      // Set by the AppImage runtime to the path of the .AppImage file.
      return environment.containsKey('APPIMAGE')
          ? DistributionChannel.github
          : DistributionChannel.none;
    default:
      return DistributionChannel.none;
  }
}
