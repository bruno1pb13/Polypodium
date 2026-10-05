import 'package:flutter_test/flutter_test.dart';
import 'package:polypodium/core/enums.dart';
import 'package:polypodium/core/notifications/reminder_payload.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ReminderPayload', () {
    test('round-trips kind and plant ids', () {
      const payload = ReminderPayload(ReminderKind.pesticide, ['a', 'b']);

      final decoded = ReminderPayload.decode(payload.encode());

      expect(decoded?.kind, ReminderKind.pesticide);
      expect(decoded?.plantIds, ['a', 'b']);
    });

    test('round-trips a care reminder with its entry type', () {
      const payload = ReminderPayload(ReminderKind.care, ['a'],
          entryType: EntryType.pruning);

      final decoded = ReminderPayload.decode(payload.encode());

      expect(decoded?.kind, ReminderKind.care);
      expect(decoded?.entryType, EntryType.pruning);
      expect(decoded?.plantIds, ['a']);
    });

    test('decodes payloads scheduled before care reminders existed', () {
      final decoded = ReminderPayload.decode(
          '{"kind": "irrigation", "plantIds": ["a", "b"]}');

      expect(decoded?.kind, ReminderKind.irrigation);
      expect(decoded?.entryType, isNull);
      expect(decoded?.plantIds, ['a', 'b']);
      // ...and irrigation/pesticide payloads still encode without one.
      expect(
          const ReminderPayload(ReminderKind.pesticide, ['a']).encode(),
          '{"kind":"pesticide","plantIds":["a"]}');
    });

    test('rejects a care payload without a known entry type', () {
      expect(ReminderPayload.decode('{"kind": "care", "plantIds": ["a"]}'),
          isNull);
      expect(
          ReminderPayload.decode(
              '{"kind": "care", "plantIds": ["a"], "entryType": "grafting"}'),
          isNull);
    });

    test('decodes missing or malformed payloads to null', () {
      expect(ReminderPayload.decode(null), isNull);
      expect(ReminderPayload.decode(''), isNull);
      expect(ReminderPayload.decode('not json'), isNull);
      expect(ReminderPayload.decode('[1, 2]'), isNull);
      expect(ReminderPayload.decode('{"kind": "unknown", "plantIds": []}'),
          isNull);
      expect(ReminderPayload.decode('{"kind": "irrigation"}'), isNull);
    });
  });

  group('ReminderSnoozeStore', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('returns pending snoozes and forgets the ones already past', () async {
      final prefs = await SharedPreferences.getInstance();
      final store = ReminderSnoozeStore(prefs);
      final now = DateTime(2026, 5, 20, 12);

      await store.add(ReminderSnooze(ReminderKind.irrigation, const ['a'],
          now.subtract(const Duration(minutes: 1))));
      await store.add(ReminderSnooze(ReminderKind.pesticide, const ['b'],
          now.add(const Duration(hours: 3))));

      final pending = await store.loadPending(now);
      expect(pending, hasLength(1));
      expect(pending.single.kind, ReminderKind.pesticide);
      expect(pending.single.plantIds, ['b']);
      expect(pending.single.at, now.add(const Duration(hours: 3)));

      // The past snooze was pruned from storage, not just filtered out.
      final later = await ReminderSnoozeStore(prefs)
          .loadPending(now.subtract(const Duration(hours: 1)));
      expect(later, hasLength(1));
    });

    test('keeps the entry type of a snoozed care reminder, and reads '
        'snoozes saved before it existed', () async {
      SharedPreferences.setMockInitialValues({
        'notification_snoozes':
            '[{"kind":"irrigation","plantIds":["a"],"at":"2026-05-20T15:00:00.000"}]',
      });
      final prefs = await SharedPreferences.getInstance();
      final store = ReminderSnoozeStore(prefs);
      final now = DateTime(2026, 5, 20, 12);

      await store.add(ReminderSnooze(
          ReminderKind.care, const ['b'], now.add(const Duration(hours: 3)),
          entryType: EntryType.fertilizer));

      final pending = await ReminderSnoozeStore(prefs).loadPending(now);
      expect(pending.map((s) => s.kind),
          [ReminderKind.irrigation, ReminderKind.care]);
      expect(pending.first.entryType, isNull);
      expect(pending.last.entryType, EntryType.fertilizer);
    });

    test('starts empty and survives corrupt storage', () async {
      SharedPreferences.setMockInitialValues(
          {'notification_snoozes': 'corrupt'});
      final prefs = await SharedPreferences.getInstance();

      expect(await ReminderSnoozeStore(prefs).loadPending(DateTime.now()),
          isEmpty);
    });
  });
}
