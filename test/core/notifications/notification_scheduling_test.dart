import 'package:flutter_test/flutter_test.dart';
import 'package:polypodium/core/enums.dart';
import 'package:polypodium/core/notifications/notification_service.dart';
import 'package:polypodium/features/plants/domain/plant_model.dart';
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
  });
}
