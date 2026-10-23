import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/links/external_links.dart';
import '../../../labels/presentation/widgets/plant_label_preview.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import 'dashboard_card.dart';

/// The kind of device the dashboard suggests installing the app on next.
enum OtherPlatform { android, desktop }

/// Computers are offered the Android app and Android the desktop versions.
/// Elsewhere (iOS, web) there is nothing to offer.
OtherPlatform? otherPlatformFor(TargetPlatform platform) => switch (platform) {
      TargetPlatform.android => OtherPlatform.desktop,
      TargetPlatform.windows ||
      TargetPlatform.linux ||
      TargetPlatform.macOS =>
        OtherPlatform.android,
      _ => null,
    };

/// Dashboard card suggesting the app on the other kind of device, until the
/// user turns it off with "don't show again".
class DashboardOtherPlatformCard extends ConsumerStatefulWidget {
  const DashboardOtherPlatformCard({super.key});

  @override
  ConsumerState<DashboardOtherPlatformCard> createState() =>
      _DashboardOtherPlatformCardState();
}

class _DashboardOtherPlatformCardState
    extends ConsumerState<DashboardOtherPlatformCard> {
  late bool _dismissed =
      ref.read(settingsRepositoryProvider).isOtherPlatformCardDismissed();

  Future<void> _dismiss() async {
    setState(() => _dismissed = true);
    await ref.read(settingsRepositoryProvider).dismissOtherPlatformCard();
  }

  @override
  Widget build(BuildContext context) {
    final other = otherPlatformFor(defaultTargetPlatform);
    if (_dismissed || other == null) return const SizedBox.shrink();

    final palette = dashboardPalette(context, ref);
    final l10n = context.l10n;
    final android = other == OtherPlatform.android;

    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          android ? l10n.otherPlatformAndroidBody : l10n.otherPlatformDesktopBody,
          style: TextStyle(fontSize: 13.5, height: 1.4, color: palette.ink),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.otherPlatformSyncNote,
          style: TextStyle(fontSize: 12.5, color: palette.inkSoft),
        ),
      ],
    );

    return DashboardCard(
      title: android
          ? l10n.otherPlatformAndroidTitle
          : l10n.otherPlatformDesktopTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (android) ...[
                // Desktop users read it with the phone they'd install on.
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SizedBox.square(
                    dimension: 96,
                    child: CustomPaint(
                      painter: QrPainter(ExternalLinks.playStore.toString()),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
              ] else ...[
                Icon(Icons.computer_outlined, size: 40, color: palette.growth),
                const SizedBox(width: 16),
              ],
              Expanded(child: text),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              alignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                TextButton(
                  onPressed: _dismiss,
                  style: TextButton.styleFrom(foregroundColor: palette.inkSoft),
                  child: Text(l10n.dontShowAgain),
                ),
                FilledButton.icon(
                  icon: Icon(android ? Icons.shop_outlined : Icons.download),
                  label: Text(android
                      ? l10n.otherPlatformAndroidAction
                      : l10n.otherPlatformDesktopAction),
                  onPressed: () => openExternalLink(
                    context,
                    android
                        ? ExternalLinks.playStore
                        : ExternalLinks.downloads(l10n.localeName),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
