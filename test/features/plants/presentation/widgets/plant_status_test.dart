import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:polypodium/core/enums.dart';
import 'package:polypodium/features/entries/domain/carencia.dart';
import 'package:polypodium/features/entries/presentation/providers/entries_providers.dart';
import 'package:polypodium/features/plants/domain/plant_model.dart';
import 'package:polypodium/features/plants/presentation/widgets/plant_status.dart';
import 'package:polypodium/features/species/domain/species_model.dart';
import 'package:polypodium/l10n/app_localizations_pt.dart';

void main() {
  setUpAll(() => initializeDateFormatting('pt'));

  final l10n = AppLocalizationsPt();
  final now = DateTime.now();

  final species = SpeciesModel(
    id: 's1',
    popularName: 'Rose',
    scientificName: 'Rosa',
    defaultIrrigationFrequencyDays: 3,
    recommendedSoilIds: ['loamy'],
    createdAt: now,
  );

  PlantWithSpecies plant({
    int? daysSinceWatering = 1,
    int? daysSincePesticide,
    int? pesticideEvery,
    PlantStatus status = PlantStatus.active,
  }) =>
      PlantWithSpecies(
        plant: PlantModel(
          id: 'p1',
          speciesId: 's1',
          nickname: 'Red Rose',
          soilId: 'loamy',
          acquisitionDate: DateTime(2023, 1, 1),
          createdAt: DateTime(2023, 1, 1),
          lastIrrigatedAt: daysSinceWatering == null
              ? null
              : now.subtract(Duration(days: daysSinceWatering)),
          lastPesticideAppliedAt: daysSincePesticide == null
              ? null
              : now.subtract(Duration(days: daysSincePesticide)),
          pesticideReapplicationDays: pesticideEvery,
          status: status,
        ),
        species: species,
      );

  group('pesticide getters', () {
    test('approaching only within the window and before the due date', () {
      expect(
          plant(daysSincePesticide: 6, pesticideEvery: 10)
              .pesticideReapplicationApproaching,
          isFalse);
      expect(
          plant(daysSincePesticide: 7, pesticideEvery: 10)
              .pesticideReapplicationApproaching,
          isTrue);
      expect(
          plant(daysSincePesticide: 9, pesticideEvery: 10)
              .pesticideReapplicationApproaching,
          isTrue);
      expect(
          plant(daysSincePesticide: 10, pesticideEvery: 10)
              .pesticideReapplicationApproaching,
          isFalse);
      expect(plant(daysSincePesticide: 9).pesticideReapplicationApproaching,
          isFalse);
    });

    test('under active control for 45 days after an application', () {
      expect(plant(daysSincePesticide: 44).pesticideUnderActiveControl, isTrue);
      expect(
          plant(daysSincePesticide: 45).pesticideUnderActiveControl, isFalse);
      expect(plant().pesticideUnderActiveControl, isFalse);
    });
  });

  group('plantListStatuses', () {
    test('empty when everything is on schedule', () {
      expect(plantListStatuses(l10n, plant(), noPlantAlerts), isEmpty);
    });

    test('overdue pesticide shows Reaplicar instead of Em controle', () {
      final statuses = plantListStatuses(l10n,
          plant(daysSincePesticide: 12, pesticideEvery: 10), noPlantAlerts);
      expect(statuses.map((s) => s.label), [l10n.pesticideReapplyBadge]);
      expect(statuses.single.tone, StatusTone.danger);
    });

    test('recent pesticide without overdue reminder is positive', () {
      final statuses = plantListStatuses(l10n,
          plant(daysSincePesticide: 3, pesticideEvery: 10), noPlantAlerts);
      expect(statuses.single.label, l10n.pesticideActiveControlBadge);
      expect(statuses.single.tone, StatusTone.positive);
    });

    test('ordered by urgency: danger, then warning, then positive', () {
      final statuses = plantListStatuses(
        l10n,
        plant(daysSinceWatering: 5, daysSincePesticide: 2),
        (
          hasActiveChlorosis: true,
          chlorosisSeverity: 3,
          hasActivePest: true,
          pestSeverity: 1,
        ),
      );
      expect(statuses.map((s) => s.label), [
        l10n.waterBadge,
        l10n.entryTypeChlorosis,
        l10n.pestBadge,
        l10n.pesticideActiveControlBadge,
      ]);
      expect(statuses.map((s) => s.tone), [
        StatusTone.danger,
        StatusTone.danger,
        StatusTone.warning,
        StatusTone.positive,
      ]);
    });

    test('carência is a warning with its end date', () {
      final carencia = CarenciaStatus(
          until: DateTime(2026, 10, 12), productNames: const ['Neem']);
      final statuses = plantListStatuses(
        l10n,
        plant(daysSinceWatering: 5, daysSincePesticide: 2),
        noPlantAlerts,
        carencia: carencia,
      );
      expect(statuses.map((s) => s.label), [
        l10n.waterBadge,
        'Carência até 12/10',
        l10n.pesticideActiveControlBadge,
      ]);
      expect(statuses[1].tone, StatusTone.warning);

      // Not shown once the plant left the collection.
      expect(
        plantListStatuses(l10n, plant(status: PlantStatus.dead), noPlantAlerts,
                carencia: carencia)
            .map((s) => s.label),
        [l10n.plantStatusDead],
      );
    });

    test('an inactive plant only shows its lifecycle status', () {
      final pws = plant(
        daysSinceWatering: 10,
        daysSincePesticide: 12,
        pesticideEvery: 10,
        status: PlantStatus.dead,
      );
      expect(pws.needsWatering, isFalse);
      expect(pws.daysRelativeToSchedule, isNull);
      expect(pws.needsPesticideReapplication, isFalse);
      expect(pws.pesticideUnderActiveControl, isFalse);

      final statuses = plantListStatuses(l10n, pws, (
        hasActiveChlorosis: true,
        chlorosisSeverity: 3,
        hasActivePest: false,
        pestSeverity: null,
      ));
      expect(statuses.map((s) => s.label), [l10n.plantStatusDead]);
      expect(statuses.single.tone, StatusTone.neutral);
    });
  });
}
