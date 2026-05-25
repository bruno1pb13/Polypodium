import 'package:flutter_test/flutter_test.dart';
import 'package:polypodium/core/notifications/notification_service.dart';

void main() {
  group('NotificationService.computeNextIrrigationDate', () {
    // Reference: Sunday 2026-05-24, 10:00
    final now = DateTime(2026, 5, 24, 10, 0);

    test('schedules tomorrow at 9h when plant was never irrigated', () {
      final result =
          NotificationService.computeNextIrrigationDate(null, 7, now);
      expect(result, DateTime(2026, 5, 25, 9));
    });

    test('schedules at frequencyDays after last irrigation', () {
      final lastIrrigated = DateTime(2026, 5, 20);
      final result = NotificationService.computeNextIrrigationDate(
          lastIrrigated, 7, now);
      expect(result, DateTime(2026, 5, 27, 9));
    });

    test('keeps the due day when 9h is still in the future', () {
      final nowEarly = DateTime(2026, 5, 27, 8, 0); // 8am
      final lastIrrigated = DateTime(2026, 5, 20);
      final result = NotificationService.computeNextIrrigationDate(
          lastIrrigated, 7, nowEarly);
      expect(result, DateTime(2026, 5, 27, 9));
    });

    test('advances to next day when 9h on the due date has already passed', () {
      // Due today (24th) but it is already 10h
      final lastIrrigated = DateTime(2026, 5, 17);
      final result = NotificationService.computeNextIrrigationDate(
          lastIrrigated, 7, now);
      expect(result, DateTime(2026, 5, 25, 9));
    });

    test('overdue plant (past due date and 9h already passed) schedules today', () {
      // base = 2026-05-23, 9h on 23rd is before now → advance +1 day = today (24th) at 9h
      // Today's 9h is still before now (10h), but the algorithm only adds one day, so
      // the result lands at 2026-05-24 09:00 — closest possible slot for an overdue plant.
      final lastIrrigated = DateTime(2026, 5, 23);
      final result =
          NotificationService.computeNextIrrigationDate(lastIrrigated, 0, now);
      expect(result, DateTime(2026, 5, 24, 9));
    });

    test('schedules at 9h exactly on the result date', () {
      final lastIrrigated = DateTime(2026, 5, 21);
      final result = NotificationService.computeNextIrrigationDate(
          lastIrrigated, 5, now);
      expect(result.hour, 9);
      expect(result.minute, 0);
      expect(result.second, 0);
    });
  });
}
