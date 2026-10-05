import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/enums.dart';
import '../../../../../core/l10n/l10n.dart';
import '../../../../settings/presentation/providers/settings_providers.dart';
import '../../providers/plant_detail_view_provider.dart';
import '../../../../../core/theme/glass_colors.dart';

/// Diary / charts / photos segmented switch of the plant detail screen.
class PlantDetailViewSelector extends ConsumerWidget {
  final String plantId;
  const PlantDetailViewSelector({super.key, required this.plantId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(plantDetailViewNotifierProvider(plantId));
    final transparencyEnabled = ref.watch(transparencyEnabledNotifierProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: transparencyEnabled
              ? ImageFilter.blur(sigmaX: 10, sigmaY: 10)
              : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: transparencyEnabled
                  ? context.glass.scrim(0.3)
                  : colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: transparencyEnabled
                    ? context.glass.tint(0.1)
                    : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                for (final view in PlantDetailView.values)
                  Expanded(
                    child: _Segment(
                      view: view,
                      selected: view == active,
                      transparent: transparencyEnabled,
                      onTap: () => ref
                          .read(
                              plantDetailViewNotifierProvider(plantId).notifier)
                          .setView(view),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  final PlantDetailView view;
  final bool selected;
  final bool transparent;
  final VoidCallback onTap;

  const _Segment({
    required this.view,
    required this.selected,
    required this.transparent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final icon = switch (view) {
      PlantDetailView.diary => Icons.article_outlined,
      PlantDetailView.charts => Icons.show_chart,
      PlantDetailView.photos => Icons.photo_library_outlined,
    };
    final fg = selected
        ? (transparent ? context.glass.fg : colorScheme.onPrimaryContainer)
        : (transparent ? context.glass.fgSubtle : colorScheme.onSurfaceVariant);

    return Semantics(
      container: true,
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        // The vertical padding of the selector lives here so it counts
        // towards the 48 dp tap target.
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: selected
                    ? (transparent
                        ? context.glass.tint(0.18)
                        : colorScheme.primaryContainer)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 16, color: fg),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      view.label(context.l10n),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: fg,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
