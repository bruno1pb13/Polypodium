import 'package:flutter_test/flutter_test.dart';
import 'package:polypodium/core/enums.dart';
import 'package:polypodium/core/notifications/notification_service.dart';
import 'package:polypodium/features/plants/domain/plant_model.dart';
import 'package:polypodium/features/reminders/domain/reminder_model.dart';

void main() {
  final t0 = DateTime(2026, 1, 1);

  PlantModel plant(String id, {PlantStatus status = PlantStatus.active}) =>
      PlantModel(
        id: id,
        speciesId: 's1',
        nickname: id,
        soilId: 'loamy',
        acquisitionDate: t0,
        createdAt: t0,
        status: status,
      );

  PlantReminder care(PlantModel plant, EntryType type, int intervalDays,
          {DateTime? lastDoneAt, bool enabled = true, String? id}) =>
      PlantReminder(
        plant: plant,
        status: ReminderStatus(
          reminder: ReminderModel(
            id: id ?? '${plant.id}-${type.name}',
            plantId: plant.id,
            entryType: type,
            intervalDays: intervalDays,
            enabled: enabled,
            createdAt: t0,
          ),
          lastDoneAt: lastDoneAt,
        ),
      );

  group('groupRemindersByDueDate', () {
    final now = DateTime(2026, 5, 10, 10);

    test('groups by (due date, entry type)', () {
      final a = plant('a');
      final b = plant('b');
      final groups = NotificationService.groupRemindersByDueDate([
        care(a, EntryType.fertilizer, 30, lastDoneAt: DateTime(2026, 4, 20)),
        care(b, EntryType.fertilizer, 10, lastDoneAt: DateTime(2026, 5, 10)),
        care(a, EntryType.pruning, 20, lastDoneAt: DateTime(2026, 4, 30)),
      ], now);

      expect(groups.keys, hasLength(2));
      expect(
          groups[(date: DateTime(2026, 5, 20), type: EntryType.fertilizer)]
              ?.map((p) => p.id),
          ['a', 'b']);
      expect(
          groups[(date: DateTime(2026, 5, 20), type: EntryType.pruning)]
              ?.map((p) => p.id),
          ['a']);
    });

    test('never-done reminders count from their creation', () {
      final groups = NotificationService.groupRemindersByDueDate(
          [care(plant('a'), EntryType.observation, 7)],
          DateTime(2026, 1, 2, 10));
      expect(groups.keys.single.date, DateTime(2026, 1, 8));
    });

    test('overdue reminders are clamped to the next reminder time', () {
      final groups = NotificationService.groupRemindersByDueDate([
        care(plant('a'), EntryType.fertilizer, 30,
            lastDoneAt: DateTime(2026, 1, 1)),
      ], now);
      expect(groups.keys.single.date, DateTime(2026, 5, 11));
    });

    test('skips non-active plants and disabled reminders', () {
      final groups = NotificationService.groupRemindersByDueDate([
        care(plant('dead', status: PlantStatus.dead), EntryType.fertilizer, 1),
        care(plant('archived', status: PlantStatus.archived), EntryType.pruning,
            1),
        care(plant('paused'), EntryType.fertilizer, 1, enabled: false),
      ], now);
      expect(groups, isEmpty);
    });

    test('a plant with duplicate reminders is listed once', () {
      final a = plant('a');
      final groups = NotificationService.groupRemindersByDueDate([
        care(a, EntryType.fertilizer, 30, id: 'r1'),
        care(a, EntryType.fertilizer, 30, id: 'r2'),
      ], now);
      expect(groups.values.single.map((p) => p.id), ['a']);
    });
  });

  group('careNotificationId', () {
    test('is deterministic and unique per (date, type)', () {
      final ids = <int>{};
      for (final type in EntryType.values) {
        for (var day = 0; day < 800; day++) {
          final date = DateTime(2026, 1, 1 + day);
          expect(ids.add(NotificationService.careNotificationId(date, type)),
              isTrue,
              reason: '$type on $date collides');
        }
      }
      expect(
          NotificationService.careNotificationId(
              DateTime(2026, 7, 16), EntryType.fertilizer),
          NotificationService.careNotificationId(
              DateTime(2026, 7, 16, 23, 59), EntryType.fertilizer));
    });

    test('stays clear of the irrigation, pesticide and snooze ranges', () {
      for (final type in EntryType.values) {
        for (final date in [
          DateTime(1970),
          DateTime(2026, 7, 16),
          DateTime(4000, 12, 31)
        ]) {
          final id = NotificationService.careNotificationId(date, type);
          // Irrigation ids are yyyymmdd (< 100 000 000), pesticide ids start
          // at 1 000 000 000 and snoozes at 1 500 000 000.
          expect(id, greaterThanOrEqualTo(100000000));
          expect(id, lessThan(1000000000));
          expect(id, lessThan(1 << 31));
        }
      }
    });
  });
}
