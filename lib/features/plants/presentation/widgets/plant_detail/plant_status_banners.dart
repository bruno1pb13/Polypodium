import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/enums.dart';
import '../../../../../core/l10n/l10n.dart';
import '../../../../entries/domain/carencia.dart';
import '../../../../weather/domain/watering_adjustment.dart';
import '../../../../weather/presentation/watering_adjustment_text.dart';
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
  final CarenciaStatus? carencia;

  const PlantCareAlerts({super.key, required this.pws, this.carencia});

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
      if (pws.activeWateringAdjustment case final adjustment?)
        _wateringAdjustmentBanner(l10n, adjustment),
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
      if (carencia case final carencia? when pws.plant.isActive)
        _carenciaBanner(l10n, carencia),
    ];

    if (banners.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Column(children: banners),
    );
  }

  Widget _wateringAdjustmentBanner(
      AppLocalizations l10n, WateringAdjustment adjustment) {
    final text = wateringAdjustmentText(l10n, adjustment);
    final last = pws.plant.lastIrrigatedAt!.toLocal();
    final next = DateTime(
        last.year, last.month, last.day + pws.scheduledFrequencyDays!);
    return PlantStatusBanner(
      emoji: text.emoji,
      title: text.label,
      subtitle: '${text.detail}. '
          '${l10n.nextWateringOn(DateFormat.Md(l10n.localeName).format(next))}',
      tone: StatusTone.neutral,
    );
  }

  Widget _carenciaBanner(AppLocalizations l10n, CarenciaStatus carencia) {
    final date = DateFormat.Md(l10n.localeName).format(carencia.until);
    return PlantStatusBanner(
      emoji: carenciaEmoji,
      title: l10n.carenciaUntil(date),
      subtitle: carencia.productNames.isEmpty
          ? l10n.carenciaDoNotHarvest(date)
          : l10n.carenciaDoNotHarvestProducts(
              carencia.productNames.join(', ')),
      tone: StatusTone.warning,
    );
  }
}
