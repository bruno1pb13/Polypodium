import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/l10n.dart';
import '../sync/sync_providers.dart';
import '../sync/sync_service.dart';

/// Fixed strip at the top of the app while a big pull runs behind it: the
/// app is usable, but what it shows may still be missing rows. Leaves on
/// its own when the pull ends, successfully or not.
class SyncProgressBanner extends ConsumerWidget {
  const SyncProgressBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(syncProgressNotifierProvider);
    final show = progress != null &&
        progress.stage == SyncStage.rest &&
        progress.large;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: (child, animation) => SizeTransition(
        sizeFactor: animation,
        alignment: Alignment.topCenter,
        child: child,
      ),
      child: show
          ? _Strip(key: const ValueKey('syncing'), progress: progress)
          : const SizedBox(width: double.infinity, key: ValueKey('empty')),
    );
  }
}

class _Strip extends StatelessWidget {
  const _Strip({super.key, required this.progress});

  final SyncProgress progress;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final total = progress.total;

    return SafeArea(
      bottom: false,
      child: Material(
        color: cs.inverseSurface,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.cloud_sync_outlined,
                      size: 18, color: cs.onInverseSurface),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.l10n.syncInBackground,
                      style: TextStyle(
                        color: cs.onInverseSurface,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (total != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      context.l10n.syncProgressCount(progress.done, total),
                      style:
                          TextStyle(color: cs.onInverseSurface, fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
            _ProgressBar(progress: progress, height: 2),
          ],
        ),
      ),
    );
  }
}

/// Covers the app while a fresh device pulls the essentials -- seconds, not
/// the minutes the history can take -- so the user doesn't land on an empty
/// garden. The pull ending, or failing, lifts it.
class SyncEssentialsOverlay extends ConsumerWidget {
  const SyncEssentialsOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(syncProgressNotifierProvider);
    if (progress == null || progress.stage != SyncStage.essentials) {
      return const SizedBox.shrink();
    }
    final total = progress.total;
    final textTheme = Theme.of(context).textTheme;

    return Positioned.fill(
      child: Material(
        color: Colors.black54,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Card(
              margin: const EdgeInsets.all(24),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_download_outlined, size: 40),
                    const SizedBox(height: 16),
                    Text(context.l10n.syncEssentialsTitle,
                        style: textTheme.titleMedium,
                        textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    Text(context.l10n.syncEssentialsBody,
                        style: textTheme.bodyMedium,
                        textAlign: TextAlign.center),
                    const SizedBox(height: 20),
                    _ProgressBar(progress: progress, height: 4),
                    if (total != null) ...[
                      const SizedBox(height: 8),
                      Text(context.l10n.syncProgressCount(progress.done, total),
                          style: textTheme.bodySmall),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Determinate once the size is known, indeterminate otherwise.
class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.progress, required this.height});

  final SyncProgress progress;
  final double height;

  @override
  Widget build(BuildContext context) {
    final total = progress.total;
    return LinearProgressIndicator(
      minHeight: height,
      value: total == null || total == 0 ? null : progress.done / total,
    );
  }
}
