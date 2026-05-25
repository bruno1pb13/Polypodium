import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../entries/presentation/providers/entries_providers.dart';
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

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
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
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.more_vert,
                          size: 20,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                    Text(
                      '${pws.species.popularName}'
                      '${pws.location != null ? ' • ${pws.location!.name}' : ''}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (days != null) ...[
                      const SizedBox(height: 8),
                      _IrrigationBadge(daysRelative: days, overdue: overdue),
                    ],
                  ],
                ),
              ),
            ],
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

    final color = overdue ? colorScheme.error : colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: overdue
            ? colorScheme.errorContainer
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_today_outlined, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}