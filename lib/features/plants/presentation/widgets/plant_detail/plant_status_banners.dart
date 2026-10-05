import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/enums.dart';
import '../../../../../core/l10n/l10n.dart';
import '../../../domain/plant_model.dart';
import '../plant_status.dart';

/// Tells what happened to a plant that left the collection, and when.
class PlantLifecycleBanner extends StatelessWidget {
  final PlantModel plant;

  const PlantLifecycleBanner({super.key, required this.plant});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final label = plant.status.label(l10n);
    final since = plant.statusChangedAt;
    return PlantStatusBanner(
      emoji: plant.status.emoji,
      title: since == null
          ? label
          : l10n.plantStatusSince(
              label, DateFormat.yMd(l10n.localeName).format(since)),
      subtitle: l10n.plantInactiveHint,
      tone: StatusTone.neutral,
    );
  }
}

class PlantCareAlerts extends StatelessWidget {
  final PlantWithSpecies pws;

  const PlantCareAlerts({super.key, required this.pws});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final wateringDays = pws.daysRelativeToSchedule;
    final pesticideDays = pws.pesticideDaysRelative;

    String overdueText(int days) =>
        days == 0 ? l10n.dueToday : l10n.daysOverdue(days);

    final banners = [
      if (pws.needsWatering && wateringDays != null)
        PlantStatusBanner(
          emoji: EntryType.irrigation.emoji,
          title: l10n.needsWater,
          subtitle: pws.plant.lastIrrigatedAt == null
              ? l10n.lastWateringNotRecorded
              : overdueText(wateringDays),
          tone: StatusTone.danger,
        ),
      if (pws.needsPesticideReapplication && pesticideDays != null)
        PlantStatusBanner(
          emoji: EntryType.pesticide.emoji,
          title: l10n.needsPesticideApplication,
          subtitle: overdueText(pesticideDays),
          tone: StatusTone.danger,
        )
      else if (pws.pesticideReapplicationApproaching && pesticideDays != null)
        PlantStatusBanner(
          emoji: EntryType.pesticide.emoji,
          title: l10n.pesticideApproachingTitle,
          subtitle: l10n.nextPesticideInDays(-pesticideDays),
          tone: StatusTone.warning,
        ),
    ];

    if (banners.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Column(children: banners),
    );
  }
}
