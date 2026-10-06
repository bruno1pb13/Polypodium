import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/glass_colors.dart';
import '../../../plants/presentation/widgets/insights/insight_palette.dart';
import '../../../settings/presentation/providers/settings_providers.dart';

/// Glass card of the dashboard: a header (title, optional trailing action)
/// over [child], in the same style as the plant insight cards.
class DashboardCard extends ConsumerWidget {
  final String? title;
  final Widget? trailing;
  final Widget child;
  final EdgeInsetsGeometry padding;

  const DashboardCard({
    super.key,
    this.title,
    this.trailing,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transparent = ref.watch(transparencyEnabledNotifierProvider);
    final palette = InsightPalette.of(context, transparent);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: transparent
            ? ImageFilter.blur(sigmaX: 10, sigmaY: 10)
            : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
        child: Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            color: transparent
                ? context.glass.scrim(0.3)
                : Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: transparent ? context.glass.tint(0.1) : Colors.transparent,
            ),
          ),
          // Ink of the InkWells inside paints here, within the rounded clip,
          // instead of on the Scaffold behind the card.
          child: Material(
            type: MaterialType.transparency,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null) ...[
                  LayoutBuilder(
                    builder: (context, constraints) => Row(
                      children: [
                        Expanded(
                          child: Semantics(
                            header: true,
                            child: Text(
                              title!,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: palette.ink,
                              ),
                            ),
                          ),
                        ),
                        // Capped so large fonts wrap it instead of pushing the
                        // title out.
                        if (trailing != null)
                          ConstrainedBox(
                            constraints: BoxConstraints(
                                maxWidth: constraints.maxWidth / 2),
                            child: trailing!,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Small text button for a card header ("Ver agenda", "Ver todas").
class DashboardCardAction extends ConsumerWidget {
  final String label;
  final VoidCallback onPressed;

  const DashboardCardAction({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transparent = ref.watch(transparencyEnabledNotifierProvider);
    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: transparent
            ? context.glass.fg
            : Theme.of(context).colorScheme.primary,
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }
}

/// The dashboard palette for the current transparency setting.
InsightPalette dashboardPalette(BuildContext context, WidgetRef ref) =>
    InsightPalette.of(context, ref.watch(transparencyEnabledNotifierProvider));
