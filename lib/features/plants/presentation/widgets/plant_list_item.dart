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

  const PlantListItem({
    super.key,
    required this.plantWithSpecies,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pws = plantWithSpecies;
    final days = pws.daysRelativeToSchedule;
    final overdue = pws.needsWatering;
    final photoAsync = ref.watch(latestPlantPhotoProvider(pws.plant.id));
    final transparencyEnabled = ref.watch(transparencyEnabledNotifierProvider);

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
                color: transparencyEnabled
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.transparent,
              ),
            ),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    _PlantThumbnail(
                      photoPath: photoAsync.valueOrNull,
                      overdue: overdue,
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
                          if (days != null && overdue) ...[
                            const SizedBox(height: 8),
                            _IrrigationBadge(
                                daysRelative: days, overdue: overdue),
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

class _IrrigationBadge extends StatelessWidget {
  final int daysRelative;
  final bool overdue;

  const _IrrigationBadge({required this.daysRelative, required this.overdue});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final label = overdue
        ? daysRelative == 0
            ? 'Hoje'
            : '${daysRelative}d atrasada'
        : 'em ${(-daysRelative)}d';

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
          Icon(Icons.calendar_today_outlined, size: 12, color: color),
          const SizedBox(width: 6),
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
