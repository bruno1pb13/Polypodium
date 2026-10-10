import 'dart:io' show Platform;

import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'distribution_channel.dart';
import 'github_update_checker.dart';
import 'play_store_update_checker.dart';
import 'update_checker.dart';

part 'update_controller.g.dart';

@Riverpod(keepAlive: true)
DistributionChannel distributionChannel(Ref ref) =>
    detectDistributionChannel();

/// Running version name, e.g. `1.2.0`.
@Riverpod(keepAlive: true)
Future<String> appVersion(Ref ref) async =>
    (await PackageInfo.fromPlatform()).version;

/// How this copy of the app looks for updates, or null when it doesn't:
/// the Microsoft Store updates its apps by itself, and debug or package
/// manager installs aren't ours to update.
@Riverpod(keepAlive: true)
Future<UpdateChecker?> updateChecker(Ref ref) async {
  switch (ref.watch(distributionChannelProvider)) {
    case DistributionChannel.playStore:
      return const PlayStoreUpdateChecker();
    case DistributionChannel.github:
      return GithubUpdateChecker(
        currentVersion: await ref.watch(appVersionProvider.future),
        assetName: githubAssetFor(Platform.operatingSystem),
      );
    case DistributionChannel.msStore:
    case DistributionChannel.none:
      return null;
  }
}

enum UpdateCheckResult { available, upToDate, failed, unsupported }

/// The update on offer, or null. Checked automatically at most once a day
/// while the app is up to date (and on every launch while an update is
/// pending, until it is installed or dismissed); any failure is silent, the
/// app is offline-first.
@Riverpod(keepAlive: true)
class UpdateController extends _$UpdateController {
  static const _lastCheckKey = 'updates.lastCheck';
  static const _dismissedKey = 'updates.dismissed';
  static const checkInterval = Duration(days: 1);

  bool _checking = false;

  @override
  AvailableUpdate? build() => null;

  /// Automatic check, throttled and quiet about dismissed updates.
  Future<void> checkIfDue() async {
    if (_checking || state != null) return;
    final prefs = await SharedPreferences.getInstance();
    final lastCheck = prefs.getInt(_lastCheckKey);
    if (lastCheck != null &&
        DateTime.now().difference(
                DateTime.fromMillisecondsSinceEpoch(lastCheck)) <
            checkInterval) {
      return;
    }
    await _check(prefs, includeDismissed: false);
  }

  /// Check asked for by the user: also brings back a dismissed update.
  Future<UpdateCheckResult> checkNow() async {
    final prefs = await SharedPreferences.getInstance();
    return _check(prefs, includeDismissed: true);
  }

  Future<UpdateCheckResult> _check(SharedPreferences prefs,
      {required bool includeDismissed}) async {
    if (_checking) return UpdateCheckResult.failed;
    _checking = true;
    try {
      final checker = await ref.read(updateCheckerProvider.future);
      if (checker == null) return UpdateCheckResult.unsupported;

      final update = await checker.check();
      if (update == null) {
        // Only an up-to-date answer starts the quiet period: a pending
        // update keeps being offered on the next launches.
        await prefs.setInt(
            _lastCheckKey, DateTime.now().millisecondsSinceEpoch);
        state = null;
        return UpdateCheckResult.upToDate;
      }
      if (!includeDismissed && prefs.getString(_dismissedKey) == update.id) {
        return UpdateCheckResult.available;
      }
      state = update;
      return UpdateCheckResult.available;
    } catch (_) {
      return UpdateCheckResult.failed;
    } finally {
      _checking = false;
    }
  }

  Future<void> install() async {
    final update = state;
    if (update == null) return;
    final checker = await ref.read(updateCheckerProvider.future);
    try {
      await checker?.install(update);
    } catch (_) {
      // The store flow or the browser failed to open: the banner stays.
    }
  }

  /// Hides [state] until a newer version than it comes out.
  Future<void> dismiss() async {
    final update = state;
    if (update == null) return;
    state = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dismissedKey, update.id);
  }
}
