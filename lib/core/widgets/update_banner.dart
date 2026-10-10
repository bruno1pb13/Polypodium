import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/l10n.dart';
import '../updates/update_controller.dart';

/// Top-of-screen strip offering a newer version of the app, from wherever
/// this copy was installed (store or GitHub). Stays until the user updates
/// or skips that version. Wired in above the Navigator, next to the sync
/// banner.
class UpdateBanner extends ConsumerWidget {
  const UpdateBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final update = ref.watch(updateControllerProvider);
    final cs = Theme.of(context).colorScheme;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: (child, animation) => SizeTransition(
        sizeFactor: animation,
        alignment: Alignment.topCenter,
        child: child,
      ),
      child: update == null
          ? const SizedBox(width: double.infinity, key: ValueKey('empty'))
          : SafeArea(
              key: ValueKey(update.id),
              bottom: false,
              child: Material(
                color: cs.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 4),
                  child: Row(
                    children: [
                      Icon(Icons.system_update_outlined,
                          size: 18, color: cs.onPrimaryContainer),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          update.version == null
                              ? context.l10n.updateAvailableNoVersion
                              : context.l10n.updateAvailable(update.version!),
                          style: TextStyle(
                            color: cs.onPrimaryContainer,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => ref
                            .read(updateControllerProvider.notifier)
                            .install(),
                        child: Text(context.l10n.updateInstall),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        tooltip: context.l10n.updateDismiss,
                        color: cs.onPrimaryContainer,
                        onPressed: () => ref
                            .read(updateControllerProvider.notifier)
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
