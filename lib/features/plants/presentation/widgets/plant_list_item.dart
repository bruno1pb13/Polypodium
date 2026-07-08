import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/enums.dart';
import '../../../entries/presentation/providers/entries_providers.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../../domain/plant_model.dart';

class PlantListItem extends ConsumerWidget {
  final PlantWithSpecies plantWithSpecies;
  final VoidCallback onTap;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback? onToggleSelect;
  final VoidCallback? onStartSelection;

  const PlantListItem({
    super.key,
    required this.plantWithSpecies,
    required this.onTap,
    this.isSelectionMode = false,
    this.isSelected = false,
    this.onToggleSelect,
    this.onStartSelection,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pws = plantWithSpecies;
    final days = pws.daysRelativeToSchedule;
    final overdue = pws.needsWatering;
    final photoAsync = ref.watch(latestPlantPhotoProvider(pws.plant.id));
    final alertStatus = ref.watch(plantAlertStatusProvider(pws.plant.id)).valueOrNull
        ?? (hasActiveChlorosis: false, chlorosisSeverity: null, hasActivePest: false, pestSeverity: null);
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
                  ? Colors.black.withValues(alpha: 0.35)
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? colorScheme.primary
                    : transparencyEnabled
                        ? Colors.white.withValues(alpha: 0.1)
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
                    GestureDetector(
                      onTap: handleThumbnailTap,
                      child: Stack(
                        children: [
                          _PlantThumbnail(
                            photoPath: photoAsync.valueOrNull,
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
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  pws.plant.nickname,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 17,
                                    color: transparencyEnabled
                                        ? Colors.white
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                    letterSpacing: 0.3,
                                    shadows: transparencyEnabled
                                        ? [
                                            const Shadow(
                                              color: Colors.black26,
                                              offset: Offset(0, 1),
                                              blurRadius: 2,
                                            ),
                                          ]
                                        : null,
                                  ),
                                ),
                              ),
                              if (pws.plant.syncStatus == SyncStatus.pending)
                                Padding(
                                  padding: const EdgeInsets.only(right: 4),
                                  child: Tooltip(
                                    message: 'Pendente de sincronização',
                                    child: Icon(
                                      Icons.cloud_upload_outlined,
                                      size: 16,
                                      color: transparencyEnabled
                                          ? Colors.orangeAccent
                                          : Colors.orange,
                                    ),
                                  ),
                                ),
                              Icon(
                                Icons.more_vert,
                                size: 20,
                                color: transparencyEnabled
                                    ? Colors.white70
                                    : Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                              ),
                            ],
                          ),
                          Text(
                            '${pws.species.popularName}'
                            '${pws.location != null ? ' • ${pws.location!.name}' : ''}',
                            style: TextStyle(
                              fontSize: 13,
                              color: transparencyEnabled
                                  ? Colors.white70
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant
                                      .withValues(alpha: 0.7),
                            ),
                          ),
                          if (days != null && overdue ||
                              alertStatus.hasActiveChlorosis ||
                              alertStatus.hasActivePest) ...[
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: [
                                if (days != null && overdue)
                                  _IrrigationBadge(
                                      daysRelative: days, overdue: overdue),
                                if (alertStatus.hasActiveChlorosis)
                                  const _AlertBadge(
                                    emoji: '🟡',
                                    label: 'Clorose',
                                    color: Color(0xFFEAB308),
                                  ),
                                if (alertStatus.hasActivePest)
                                  const _AlertBadge(
                                    emoji: '🐛',
                                    label: 'Praga',
                                    color: Color(0xFFF97316),
                                  ),
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

  @override
  Widget build(BuildContext context) {
    if (photoPath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(photoPath!),
          width: 72,
          height: 72,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _ThumbnailPlaceholder(overdue: overdue),
        ),
      );
    }

    return _ThumbnailPlaceholder(overdue: overdue);
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
        color: overdue ? colorScheme.errorContainer : colorScheme.primaryContainer,
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

class _AlertBadge extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;

  const _AlertBadge({
    required this.emoji,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 11)),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _IrrigationBadge extends StatelessWidget {
  final int daysRelative;
  final bool overdue;

  const _IrrigationBadge({required this.daysRelative, required this.overdue});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = overdue ? colorScheme.onErrorContainer : Colors.white;
    final bgColor = overdue
        ? colorScheme.errorContainer.withValues(alpha: 0.8)
        : Colors.white.withValues(alpha: 0.15);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: overdue ? Colors.transparent : Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.water_drop, size: 13, color: color),
          const SizedBox(width: 6),
          Text(
            'Irrigação',
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
