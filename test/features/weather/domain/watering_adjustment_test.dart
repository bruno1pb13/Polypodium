import 'package:flutter_test/flutter_test.dart';
import 'package:polypodium/core/utils/date_utils.dart';
import 'package:polypodium/features/plants/domain/plant_model.dart';
import 'package:polypodium/features/species/domain/species_model.dart';
import 'package:polypodium/features/weather/domain/watering_adjustment.dart';

void main() {
  final watered = DateTime(2026, 10, 12, 8, 30);
  final now = DateTime(2026, 10, 15, 10);

  WateringAdjustment adjustment({
    int shift = 2,
    DateTime? lastWateredAt,
    int frequency = 4,
    DateTime? fetchedAt,
  }) =>
      WateringAdjustment(
        plantId: 'p1',
        lastWateredAt: lastWateredAt ?? watered,
        frequencyDays: frequency,
        shiftDays: shift,
        reason: WateringAdjustmentReason.rain,
        rainMm: 12,
        fetchedAt: fetchedAt ?? now.subtract(const Duration(hours: 2)),
      );

  group('appliesTo', () {
    test('the same cycle, fetched recently', () {
      expect(
          adjustment().appliesTo(
              lastIrrigatedAt: watered, frequencyDays: 4, now: now),
          isTrue);
      // Stored dates may lose their milliseconds.
      expect(
          adjustment(lastWateredAt: watered.add(const Duration(milliseconds: 400)))
              .appliesTo(lastIrrigatedAt: watered, frequencyDays: 4, now: now),
          isTrue);
    });

    test('not after a new watering, another interval or when stale', () {
      final a = adjustment();
      expect(
          a.appliesTo(
              lastIrrigatedAt: watered.add(const Duration(days: 2)),
              frequencyDays: 4,
              now: now),
          isFalse);
      expect(a.appliesTo(lastIrrigatedAt: null, frequencyDays: 4, now: now),
          isFalse);
      expect(
          a.appliesTo(lastIrrigatedAt: watered, frequencyDays: 5, now: now),
          isFalse);
      expect(
          adjustment(fetchedAt: now.subtract(const Duration(days: 4)))
              .appliesTo(lastIrrigatedAt: watered, frequencyDays: 4, now: now),
          isFalse);
      expect(
          adjustment(shift: 0)
              .appliesTo(lastIrrigatedAt: watered, frequencyDays: 4, now: now),
          isFalse);
    });
  });

  test('fromJson reads the server response and skips malformed rows', () {
    final a = WateringAdjustment.fromJson({
      'plantId': 'p1',
      'lastWateredAt': '2026-10-12T08:30:00.000',
      'frequencyDays': 4,
      'shiftDays': -1,
      'reason': 'heat',
      'rainMm': 0,
    }, fetchedAt: now)!;
    expect(a.lastWateredAt, watered);
    expect(a.shiftDays, -1);
    expect(a.reason, WateringAdjustmentReason.heat);

    expect(
        WateringAdjustment.fromJson({'plantId': 'p1', 'shiftDays': 1},
            fetchedAt: now),
        isNull);
    expect(
        WateringAdjustment.fromJson({
          'plantId': 'p1',
          'lastWateredAt': '2026-10-12T08:30:00.000',
          'frequencyDays': 4,
          'shiftDays': 1,
          'reason': 'from-the-future',
        }, fetchedAt: now)!
            .reason,
        WateringAdjustmentReason.none);
  });

  group('PlantWithSpecies', () {
    final species = SpeciesModel(
      id: 's1',
      scientificName: 'Nephrolepis exaltata',
      popularName: 'Fern',
      defaultIrrigationFrequencyDays: 4,
      recommendedSoilIds: const [],
      createdAt: DateTime(2026, 1, 1),
    );
    final realNow = DateTime.now();
    final lastWatered = DateTime(realNow.year, realNow.month, realNow.day - 4, 8);

    PlantWithSpecies plant({WateringAdjustment? adjustment}) =>
        PlantWithSpecies(
          plant: PlantModel(
            id: 'p1',
            speciesId: 's1',
            nickname: 'Fern',
            soilId: 'loamy',
            acquisitionDate: DateTime(2026, 1, 1),
            createdAt: DateTime(2026, 1, 1),
            lastIrrigatedAt: lastWatered,
          ),
          species: species,
          wateringAdjustment: adjustment,
        );

    test('without an adjustment the interval alone decides', () {
      final p = plant();
      expect(calendarDaysBetween(lastWatered), 4);
      expect(p.needsWatering, isTrue);
      expect(p.daysRelativeToSchedule, 0);
      expect(p.wateringShiftDays, 0);
    });

    test('a postponement moves the due date and clears needsWatering', () {
      final p = plant(
          adjustment: adjustment(
              lastWateredAt: lastWatered, fetchedAt: realNow));
      expect(p.activeWateringAdjustment, isNotNull);
      expect(p.scheduledFrequencyDays, 6);
      expect(p.needsWatering, isFalse);
      expect(p.daysRelativeToSchedule, -2);
    });

    test('an adjustment of another cycle is ignored', () {
      final p = plant(
          adjustment: adjustment(
              lastWateredAt: lastWatered.subtract(const Duration(days: 4)),
              fetchedAt: realNow));
      expect(p.activeWateringAdjustment, isNull);
      expect(p.needsWatering, isTrue);
    });
  });
}
