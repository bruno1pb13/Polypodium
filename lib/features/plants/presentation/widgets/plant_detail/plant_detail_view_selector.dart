import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/enums.dart';
import '../../../../../core/l10n/l10n.dart';
import '../../../../settings/presentation/providers/settings_providers.dart';
import '../../providers/plant_detail_view_provider.dart';

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
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: transparencyEnabled
                  ? Colors.black.withValues(alpha: 0.3)
                  : colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: transparencyEnabled
                    ? Colors.white.withValues(alpha: 0.1)
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
        ? (transparent ? Colors.white : colorScheme.onPrimaryContainer)
        : (transparent ? Colors.white60 : colorScheme.onSurfaceVariant);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? (transparent
                  ? Colors.white.withValues(alpha: 0.18)
                  : colorScheme.primaryContainer)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: fg),
            const SizedBox(width: 6),
            Text(
              view.label(context.l10n),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
