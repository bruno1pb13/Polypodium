import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sync_banner_controller.g.dart';

enum SyncBannerKind { success, offline }

class SyncBannerState {
  final SyncBannerKind kind;

  /// Number of synced items when [kind] is [SyncBannerKind.success].
  /// The user-facing message is built (localized) by the banner widget.
  final int downloadedCount;

  const SyncBannerState({required this.kind, this.downloadedCount = 0});
}

/// Transient top-of-screen banner shown for background sync activity: a
/// green line when new content was pulled down, a red line when a sync
/// attempt couldn't reach the server. Both auto-dismiss after a few
/// seconds -- the app must keep working normally with local data either way.
@Riverpod(keepAlive: true)
class SyncBannerController extends _$SyncBannerController {
  Timer? _dismissTimer;

  @override
  SyncBannerState? build() {
    ref.onDispose(() => _dismissTimer?.cancel());
    return null;
  }

  void showDownloaded(int count) {
    _show(SyncBannerState(
      kind: SyncBannerKind.success,
      downloadedCount: count,
    ));
  }

  void showOffline() {
    _show(const SyncBannerState(kind: SyncBannerKind.offline));
  }

  void _show(SyncBannerState next) {
    _dismissTimer?.cancel();
    state = next;
    _dismissTimer = Timer(const Duration(seconds: 4), () {
      state = null;
    });
  }
}
