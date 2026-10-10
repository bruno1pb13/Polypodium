import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/enums.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../entries/presentation/providers/carencia_providers.dart';
import '../../../entries/presentation/providers/entries_providers.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../../domain/plant_model.dart';
import 'plant_status.dart';
import '../../../../core/theme/glass_colors.dart';
import 'plant_short_code_text.dart';

class PlantListItem extends ConsumerWidget {
  final PlantWithSpecies plantWithSpecies;
  final VoidCallback onTap;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback? onToggleSelect;
  final VoidCallback? onStartSelection;

  /// Adds the plant's pot to the subtitle line, after the location.
  final bool showPot;

  const PlantListItem({
    super.key,
    required this.plantWithSpecies,
    required this.onTap,
    this.isSelectionMode = false,
    this.isSelected = false,
    this.onToggleSelect,
    this.onStartSelection,
    this.showPot = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pws = plantWithSpecies;
    final overdue = pws.needsWatering;
    final photoAsync = ref.watch(plantCoverPhotoProvider(pws.plant.id));
    final alertStatus =
        ref.watch(plantAlertStatusProvider(pws.plant.id)).value ??
            noPlantAlerts;
    final carencia = ref.watch(plantCarenciaProvider(pws.plant.id));
    final statuses = plantListStatuses(context.l10n, pws, alertStatus,
        carencia: carencia);
    final transparencyEnabled = ref.watch(transparencyEnabledNotifierProvider);
    final colorScheme = Theme.of(context).colorScheme;

    void handleThumbnailTap() {
      if (isSelectionMode) {
        onToggleSelect?.call();
      } else {
        onStartSelection?.call();
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: transparencyEnabled
              ? ImageFilter.blur(sigmaX: 10, sigmaY: 10)
              : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
          child: Container(
            decoration: BoxDecoration(
              color: transparencyEnabled
                  ? context.glass.glassFill
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? colorScheme.primary
                    : transparencyEnabled
                        ? context.glass.tint(0.1)
                        : Colors.transparent,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: InkWell(
              onTap: isSelectionMode ? onToggleSelect : onTap,
              onLongPress: isSelectionMode ? null : onStartSelection,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Semantics(
                      container: true,
                      checked: isSelectionMode ? isSelected : null,
                      label: context.l10n.selectPlant(pws.plant.nickname),
                      child: GestureDetector(
                        onTap: handleThumbnailTap,
                        child: Stack(
                          children: [
                            _PlantThumbnail(
                              photoPath: photoAsync.value,
                              overdue: overdue,
                            ),
                            if (isSelectionMode)
                              Positioned.fill(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.black.withValues(alpha: 0.35)
                                        : Colors.black.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Icon(
                                      isSelected
                                          ? Icons.check_circle
                                          : Icons.circle_outlined,
                                      color: Colors.white,
                                      size: 26,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        pws.plant.nickname,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 17,
                                          color: transparencyEnabled
                                              ? context.glass.fg
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                          letterSpacing: 0.3,
                                          shadows: transparencyEnabled
                                              ? [
                                                  Shadow(
                                                    color: context.glass.shadow(Colors.black26),
                                                    offset: Offset(0, 1),
                                                    blurRadius: 2,
                                                  ),
                                                ]
                                              : null,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    PlantShortCodeText(
                                      pws.plant.shortCode,
                                      color: transparencyEnabled
                                          ? context.glass.fgFaint
                                          : Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant
                                              .withValues(alpha: 0.6),
                                    ),
                                  ],
                                ),
                              ),
                              if (pws.isPendingSync)
                                Padding(
                                  padding: const EdgeInsets.only(right: 4),
                                  child: Tooltip(
                                    message: context.l10n.pendingSync,
                                    child: Icon(
                                      Icons.cloud_upload_outlined,
                                      size: 16,
                                      color: transparencyEnabled
                                          ? context.glass.warning
                                          : Colors.orange,
                                    ),
                                  ),
                                ),
                              Icon(
                                Icons.more_vert,
                                size: 20,
                                color: transparencyEnabled
                                    ? context.glass.fgMuted
                                    : Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                              ),
                            ],
                          ),
                          Text(
                            '${pws.species.popularName}'
                            '${pws.location != null ? ' • ${pws.location!.name}' : ''}'
                            '${showPot && pws.pot != null ? ' • ${pws.pot!.kind.emoji} ${pws.pot!.name}' : ''}',
                            style: TextStyle(
                              fontSize: 13,
                              color: transparencyEnabled
                                  ? context.glass.fgMuted
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant
                                      .withValues(alpha: 0.7),
                            ),
                          ),
                          if (statuses.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: [
                                for (final status in statuses)
                                  PlantStatusChip.fromStatus(status),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
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

class _PlantThumbnail extends StatelessWidget {
  final String? photoPath;
  final bool overdue;

  const _PlantThumbnail({this.photoPath, required this.overdue});

  static const _size = 72.0;

  @override
  Widget build(BuildContext context) {
    final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          _ThumbnailPlaceholder(overdue: overdue),
          if (photoPath != null)
            Image.file(
              File(photoPath!),
              width: _size,
              height: _size,
              fit: BoxFit.cover,
              // Decodifica já no tamanho do thumbnail em vez da foto inteira.
              cacheWidth: (_size * devicePixelRatio).round(),
              gaplessPlayback: true,
              excludeFromSemantics: true,
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                if (wasSynchronouslyLoaded) return child;
                return AnimatedOpacity(
                  opacity: frame == null ? 0 : 1,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  child: child,
                );
              },
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
        ],
      ),
    );
  }
}

class _ThumbnailPlaceholder extends StatelessWidget {
  final bool overdue;

  const _ThumbnailPlaceholder({required this.overdue});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color:
            overdue ? colorScheme.errorContainer : colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.local_florist_outlined,
        size: 32,
        color: overdue ? colorScheme.error : colorScheme.primary,
      ),
    );
  }
}
