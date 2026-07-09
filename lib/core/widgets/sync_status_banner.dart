import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../sync/sync_banner_controller.dart';

/// Top-of-screen strip reporting background sync activity: green when new
/// content came down, red when the last attempt couldn't reach the server.
/// Sits above the whole app (wired in via MaterialApp.builder) so it shows
/// no matter which screen is on top, and never blocks interaction with it.
class SyncStatusBanner extends ConsumerWidget {
  const SyncStatusBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final banner = ref.watch(syncBannerControllerProvider);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: (child, animation) => SizeTransition(
        sizeFactor: animation,
        alignment: Alignment.topCenter,
        child: child,
      ),
      child: banner == null
          ? const SizedBox(width: double.infinity, key: ValueKey('empty'))
          : _Banner(key: ValueKey(banner.message), state: banner),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({super.key, required this.state});

  final SyncBannerState state;

  @override
  Widget build(BuildContext context) {
    final isSuccess = state.kind == SyncBannerKind.success;
    final color = isSuccess ? Colors.green.shade600 : Colors.red.shade600;
    final icon =
        isSuccess ? Icons.cloud_done_outlined : Icons.cloud_off_outlined;

    return SafeArea(
      bottom: false,
      child: Material(
        color: color,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(icon, size: 18, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  state.message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
