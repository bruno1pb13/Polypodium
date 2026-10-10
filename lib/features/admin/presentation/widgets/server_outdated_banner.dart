import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n.dart';
import '../providers/server_update_notice.dart';

/// Top-of-screen strip telling a server admin that the server runs an older
/// version than the newest release. Informational only: there is nothing to
/// do from the app besides hiding it. Wired in above the Navigator, next to
/// the sync and app update banners.
class ServerOutdatedBanner extends ConsumerWidget {
  const ServerOutdatedBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notice = ref.watch(serverUpdateNoticeProvider);
    final cs = Theme.of(context).colorScheme;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: (child, animation) => SizeTransition(
        sizeFactor: animation,
        alignment: Alignment.topCenter,
        child: child,
      ),
      child: notice == null
          ? const SizedBox(width: double.infinity, key: ValueKey('empty'))
          : SafeArea(
              key: ValueKey('${notice.serverUrl}-${notice.latestVersion}'),
              bottom: false,
              child: Material(
                color: cs.tertiaryContainer,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 4),
                  child: Row(
                    children: [
                      Icon(Icons.dns_outlined,
                          size: 18, color: cs.onTertiaryContainer),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          context.l10n.serverOutdatedBanner(
                              notice.currentVersion, notice.latestVersion),
                          style: TextStyle(
                            color: cs.onTertiaryContainer,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        tooltip: context.l10n.serverOutdatedDismiss,
                        color: cs.onTertiaryContainer,
                        onPressed: () => ref
                            .read(serverUpdateNoticeProvider.notifier)
                            .dismiss(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
