import 'package:flutter/material.dart';

import '../../domain/plant_model.dart';

class PlantListItem extends StatelessWidget {
  final PlantWithSpecies plantWithSpecies;
  final VoidCallback onTap;

  const PlantListItem({
    super.key,
    required this.plantWithSpecies,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final pws = plantWithSpecies;
    final days = pws.daysRelativeToSchedule;
    final overdue = pws.needsWatering;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor:
            overdue ? colorScheme.errorContainer : colorScheme.primaryContainer,
        child: Icon(
          overdue ? Icons.water_drop : Icons.check_circle_outline,
          color: overdue ? colorScheme.error : colorScheme.primary,
        ),
      ),
      title: Text(pws.plant.nickname,
          style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
          '${pws.species.popularName}${pws.location != null ? ' • ${pws.location!.name}' : ''}'),
      trailing: _IrrigationBadge(daysRelative: days, overdue: overdue),
      onTap: onTap,
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: overdue ? colorScheme.errorContainer : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: overdue ? colorScheme.error : colorScheme.onSurfaceVariant, // ignore: deprecated_member_use
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
