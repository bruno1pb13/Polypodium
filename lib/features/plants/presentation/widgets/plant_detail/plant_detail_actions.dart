import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/enums.dart';
import '../../../../../core/l10n/l10n.dart';
import '../../../domain/plant_model.dart';
import '../../providers/plants_providers.dart';

/// App bar menu that moves the plant to any of the other statuses.
class PlantStatusMenuButton extends ConsumerWidget {
  final PlantModel plant;

  const PlantStatusMenuButton({super.key, required this.plant});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<PlantStatus>(
      icon: const Icon(Icons.inventory_2_outlined),
      tooltip: context.l10n.plantStatusChange,
      onSelected: (status) =>
          ref.read(plantsNotifierProvider.notifier).setStatus(plant.id, status),
      itemBuilder: (ctx) => [
        for (final status in PlantStatus.values)
          if (status != plant.status)
            PopupMenuItem(
              value: status,
              child: Text(_statusActionLabel(ctx, status)),
            ),
      ],
    );
  }

  static String _statusActionLabel(BuildContext context, PlantStatus status) =>
      switch (status) {
        PlantStatus.active => context.l10n.plantStatusReactivate,
        PlantStatus.dead => context.l10n.plantStatusMarkDead,
        PlantStatus.donated => context.l10n.plantStatusMarkDonated,
        PlantStatus.archived => context.l10n.plantStatusArchive,
      };
}

enum _DeleteChoice { archive, delete }

/// Asks to delete the plant, offering to archive it instead while it is
/// active. Deleting pops the plant's screen ([context]'s route).
Future<void> confirmDeletePlant(
  BuildContext context,
  WidgetRef ref,
  String plantId,
) async {
  final plant = await ref.read(plantsRepositoryProvider).getById(plantId);
  if (!context.mounted) return;
  final canArchive = plant != null && plant.isActive;
  final choice = await showDialog<_DeleteChoice>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(ctx.l10n.deletePlantTitle),
      content: Text(canArchive
          ? '${ctx.l10n.deletePlantBody}\n\n${ctx.l10n.deletePlantArchiveHint}'
          : ctx.l10n.deletePlantBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(ctx.l10n.cancel),
        ),
        if (canArchive)
          TextButton(
            onPressed: () => Navigator.pop(ctx, _DeleteChoice.archive),
            child: Text(ctx.l10n.plantStatusArchive),
          ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, _DeleteChoice.delete),
          child: Text(ctx.l10n.delete),
        ),
      ],
    ),
  );
  if (!context.mounted) return;
  final notifier = ref.read(plantsNotifierProvider.notifier);
  switch (choice) {
    case _DeleteChoice.archive:
      await notifier.setStatus(plantId, PlantStatus.archived);
    case _DeleteChoice.delete:
      final navigator = Navigator.of(context);
      await notifier.delete(plantId);
      navigator.pop();
    case null:
      break;
  }
}
