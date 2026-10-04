import 'package:flutter_test/flutter_test.dart';
import 'package:polypodium/core/utils/date_utils.dart';

void main() {
  group('calendarDaysBetween', () {
    test('counts calendar days, not 24 h blocks', () {
      expect(
        calendarDaysBetween(
            DateTime(2026, 10, 3, 23), DateTime(2026, 10, 4, 8)),
        1,
      );
    });

    test('same day is zero regardless of time', () {
      expect(
        calendarDaysBetween(
            DateTime(2026, 10, 4, 0, 1), DateTime(2026, 10, 4, 23, 59)),
        0,
      );
    });

    test('spans months and years', () {
      expect(
          calendarDaysBetween(DateTime(2025, 12, 31), DateTime(2026, 1, 1)), 1);
      expect(
          calendarDaysBetween(DateTime(2026, 2, 1), DateTime(2026, 3, 1)), 28);
    });

    test('negative when from is after to', () {
      expect(calendarDaysBetween(DateTime(2026, 10, 5), DateTime(2026, 10, 4)),
          -1);
    });
  });
}
