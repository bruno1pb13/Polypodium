import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/glass_colors.dart';
import '../../../plants/domain/plant_model.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../providers/pots_providers.dart';
import '../screens/pot_detail_screen.dart';
import 'pot_actions.dart';
import 'pot_ui.dart';

/// The plant's pot (opening it), the plants sharing it and the action to
/// move the plant to another pot.
class PlantPotCard extends ConsumerWidget {
  final PlantModel plant;

  const PlantPotCard({super.key, required this.plant});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final transparent = ref.watch(transparencyEnabledNotifierProvider);
    final potId = plant.potId;
    final pot =
        potId == null ? null : ref.watch(potWithPlantsProvider(potId)).value;
    final others = [
      if (pot != null)
        for (final p in pot.plants)
          if (p.plant.id != plant.id)
            '${p.plant.nickname} #${p.plant.shortCode}',
    ];
    final muted = transparent ? context.glass.fgMuted : null;
    final strong = transparent ? context.glass.fg : null;
    final specs = pot == null ? null : potSpecs(l10n, pot.pot);
    final changeButton = TextButton.icon(
      onPressed: () => pickPotAndMovePlants(context, ref, [plant.id],
          currentPotId: plant.potId, title: l10n.changePot),
      icon:
          Icon(Icons.swap_horiz, color: transparent ? context.glass.fg : null),
      label: Text(
        l10n.changePot,
        style: TextStyle(
          color: transparent ? context.glass.fg : null,
          fontWeight: FontWeight.w600,
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: transparent
              ? ImageFilter.blur(sigmaX: 10, sigmaY: 10)
              : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            decoration: BoxDecoration(
              color: transparent
                  ? context.glass.scrim(0.3)
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color:
                    transparent ? context.glass.tint(0.1) : Colors.transparent,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (pot == null)
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.yard_outlined,
                              size: 20,
                              color:
                                  transparent ? context.glass.fgSubtle : null),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Text(
                              '${l10n.potLabel}: ${l10n.noPot}',
                              style: TextStyle(color: muted),
                            ),
                          ),
                        ],
                      ),
                      changeButton,
                    ],
                  )
                else ...[
                  Material(
                    type: MaterialType.transparency,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PotDetailScreen(potId: pot.pot.id),
                        ),
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 48),
                        child: Row(
                          children: [
                            PotKindBadge(kind: pot.pot.kind, size: 28),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(l10n.potLabel,
                                      style: TextStyle(
                                          color: muted, fontSize: 12)),
                                  Text(
                                    pot.pot.name,
                                    style: TextStyle(
                                        color: strong,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  if (specs != null)
                                    Text(specs,
                                        style: TextStyle(
                                            color: muted, fontSize: 12)),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right,
                                size: 20,
                                color: transparent
                                    ? context.glass.fgSubtle
                                    : null),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (others.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        l10n.sharesPotWith(others.join(', ')),
                        style: TextStyle(color: muted, fontSize: 13),
                      ),
                    ),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: changeButton,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
