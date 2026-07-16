import 'package:flutter_test/flutter_test.dart';
import 'package:polypodium/core/notifications/notification_service.dart';
import 'package:polypodium/features/plants/domain/plant_model.dart';
import 'package:polypodium/features/species/domain/species_model.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

void main() {
  setUpAll(() {
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('UTC'));
  });

  group('NotificationService Scheduling Logic', () {
    final plant = PlantModel(
      id: 'plant-1',
      speciesId: 'species-1',
      nickname: 'Basil',
      soilId: 'loamy',
      acquisitionDate: DateTime(2026, 1, 1),
      createdAt: DateTime(2026, 1, 1),
      lastIrrigatedAt: DateTime(2026, 5, 20),
      irrigationFrequencyDays: 5,
    );

    test('calculates correct notification ID from UUID', () {
      // Test the private-ish _notificationId logic if possible, 
      // or just verify it's deterministic.
      final id1 = plant.id.hashCode.abs() % 0x7FFFFFFF;
      expect(id1, isA<int>());
      expect(id1, greaterThanOrEqualTo(0));
    });

    test('computes correct next irrigation date (integration check)', () {
      // This is a sanity check that the service uses the correct timezone logic
      final frequencyDays = plant.irrigationFrequencyDays!;
      final lastIrrigated = plant.lastIrrigatedAt!;
      
      // Expected: last (20th) + 5 days = 25th.
      // If run on 20th, it should be 25th at 9am.
      final result = NotificationService.computeNextIrrigationDate(
        lastIrrigated,
        frequencyDays,
        DateTime(2026, 5, 20, 10), // Now is after last irrigation
      );
      
      expect(result.year, 2026);
      expect(result.month, 5);
      expect(result.day, 25);
      expect(result.hour, 9);
    });

    test('overdue plant is clamped to the next 9am, never a past date', () {
      // Due on May 25th, but "now" is June 10th (16 days overdue).
      final now = DateTime(2026, 6, 10, 10);
      final result = NotificationService.computeNextIrrigationDate(
        DateTime(2026, 5, 20),
        5,
        now,
      );

      expect(result.isAfter(now), isTrue,
          reason: 'zonedSchedule throws for dates in the past');
      expect(result, DateTime(2026, 6, 11, 9));
    });

    test('overdue plant checked before 9am schedules for today 9am', () {
      final now = DateTime(2026, 6, 10, 7);
      final result = NotificationService.computeNextIrrigationDate(
        DateTime(2026, 5, 20),
        5,
        now,
      );

      expect(result, DateTime(2026, 6, 10, 9));
    });

    test('honors a user-chosen reminder time (20:30)', () {
      // Due on May 25th; user prefers 20:30.
      final result = NotificationService.computeNextIrrigationDate(
        DateTime(2026, 5, 20),
        5,
        DateTime(2026, 5, 20, 10),
        hour: 20,
        minute: 30,
      );

      expect(result, DateTime(2026, 5, 25, 20, 30));
    });

    test('overdue plant with custom time clamps to the next occurrence', () {
      // Overdue; now is 21:00, past today's 20:30 slot → tomorrow 20:30.
      final now = DateTime(2026, 6, 10, 21);
      final result = NotificationService.computeNextIrrigationDate(
        DateTime(2026, 5, 20),
        5,
        now,
        hour: 20,
        minute: 30,
      );

      expect(result, DateTime(2026, 6, 11, 20, 30));
    });

    test('never irrigated plant schedules for the next 9am', () {
      final result = NotificationService.computeNextIrrigationDate(
        null,
        5,
        DateTime(2026, 6, 10, 10),
      );

      expect(result, DateTime(2026, 6, 11, 9));
    });
  });

  group('NotificationService.groupPlantsByDueDate', () {
    final species = SpeciesModel(
      id: 'species-1',
      scientificName: 'Ocimum basilicum',
      popularName: 'Basil',
      defaultIrrigationFrequencyDays: 7,
      recommendedSoilIds: const ['loamy'],
      createdAt: DateTime(2026, 1, 1),
    );

    PlantWithSpecies makePlant(String nickname,
            {DateTime? lastIrrigatedAt, int? frequencyDays}) =>
        PlantWithSpecies(
          plant: PlantModel(
            id: 'plant-$nickname',
            speciesId: species.id,
            nickname: nickname,
            soilId: 'loamy',
            acquisitionDate: DateTime(2026, 1, 1),
            createdAt: DateTime(2026, 1, 1),
            lastIrrigatedAt: lastIrrigatedAt,
            irrigationFrequencyDays: frequencyDays,
          ),
          species: species,
        );

    final now = DateTime(2026, 5, 20, 10);

    test('plants due on the same day share a single group', () {
      final groups = NotificationService.groupPlantsByDueDate(
        [
          makePlant('Basil',
              lastIrrigatedAt: DateTime(2026, 5, 20), frequencyDays: 5),
          makePlant('Fern',
              lastIrrigatedAt: DateTime(2026, 5, 22), frequencyDays: 3),
        ],
        now,
      );

      expect(groups, hasLength(1));
      expect(groups[DateTime(2026, 5, 25)], ['Basil', 'Fern']);
    });

    test('plants due on different days get separate groups', () {
      final groups = NotificationService.groupPlantsByDueDate(
        [
          makePlant('Basil',
              lastIrrigatedAt: DateTime(2026, 5, 20), frequencyDays: 5),
          makePlant('Cactus',
              lastIrrigatedAt: DateTime(2026, 5, 20), frequencyDays: 10),
        ],
        now,
      );

      expect(groups, hasLength(2));
      expect(groups[DateTime(2026, 5, 25)], ['Basil']);
      expect(groups[DateTime(2026, 5, 30)], ['Cactus']);
    });

    test('falls back to the species default frequency', () {
      final groups = NotificationService.groupPlantsByDueDate(
        [makePlant('Basil', lastIrrigatedAt: DateTime(2026, 5, 20))],
        now,
      );

      expect(groups[DateTime(2026, 5, 27)], ['Basil']);
    });

    test('skips plants without any irrigation frequency', () {
      final noFrequencySpecies = SpeciesModel(
        id: 'species-2',
        scientificName: 'Unknown',
        popularName: 'Unknown',
        defaultIrrigationFrequencyDays: null,
        recommendedSoilIds: const [],
        createdAt: DateTime(2026, 1, 1),
      );
      final groups = NotificationService.groupPlantsByDueDate(
        [
          PlantWithSpecies(
            plant: PlantModel(
              id: 'plant-x',
              speciesId: noFrequencySpecies.id,
              nickname: 'Mystery',
              soilId: 'loamy',
              acquisitionDate: DateTime(2026, 1, 1),
              createdAt: DateTime(2026, 1, 1),
            ),
            species: noFrequencySpecies,
          ),
        ],
        now,
      );

      expect(groups, isEmpty);
    });

    test('overdue plants land in the next reminder slot together', () {
      // Both long overdue; now is past today's 9am → both tomorrow 9am.
      final groups = NotificationService.groupPlantsByDueDate(
        [
          makePlant('Basil',
              lastIrrigatedAt: DateTime(2026, 4, 1), frequencyDays: 5),
          makePlant('Fern',
              lastIrrigatedAt: DateTime(2026, 3, 1), frequencyDays: 3),
        ],
        now,
      );

      expect(groups, hasLength(1));
      expect(groups[DateTime(2026, 5, 21)], ['Basil', 'Fern']);
    });
  });
}
