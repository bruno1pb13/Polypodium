import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:polypodium/core/database/app_database.dart';
import 'package:polypodium/core/enums.dart';
import 'package:polypodium/core/l10n/l10n.dart';
import 'package:polypodium/core/notifications/notification_service.dart';
import 'package:polypodium/features/agenda/data/home_widget_service.dart';
import 'package:polypodium/features/agenda/domain/home_widget_snapshot.dart';
import 'package:polypodium/features/plants/data/plants_repository.dart';
import 'package:polypodium/features/plants/domain/plant_model.dart';
import 'package:polypodium/features/reminders/data/reminders_repository.dart';
import 'package:polypodium/features/reminders/domain/reminder_model.dart';
import 'package:polypodium/features/species/data/species_repository.dart';
import 'package:polypodium/features/species/domain/species_model.dart';

class _NoopNotifications implements INotificationService {
  @override
  Future<void> rescheduleAll(List<PlantWithSpecies> plants,
      {List<PlantReminder> reminders = const []}) async {}
}

class _FakeGateway implements HomeWidgetGateway {
  final published = <HomeWidgetSnapshot>[];

  @override
  Future<void> publish(HomeWidgetSnapshot snapshot) async =>
      published.add(snapshot);
}

void main() {
  group('publishHomeWidgetFromDatabase', () {
    late AppDatabase db;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    DateTime daysAgo(int days) =>
        DateTime(today.year, today.month, today.day - days, 10);

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      await SpeciesRepository(db).save(SpeciesModel(
        id: 'species1',
        scientificName: 'Sci',
        popularName: 'Pop',
        defaultIrrigationFrequencyDays: 3,
        recommendedSoilIds: const ['loamy'],
        createdAt: DateTime(2026, 1, 1),
      ));
      final plants = PlantsRepository(db, _NoopNotifications());
      Future<void> plant(String id, DateTime lastIrrigatedAt,
              {PlantStatus status = PlantStatus.active}) =>
          plants.save(PlantModel(
            id: id,
            speciesId: 'species1',
            nickname: 'Plant $id',
            soilId: 'loamy',
            acquisitionDate: DateTime(2026, 1, 1),
            createdAt: DateTime(2026, 1, 1),
            lastIrrigatedAt: lastIrrigatedAt,
            status: status,
          ));
      await plant('late', daysAgo(5));
      await plant('due', daysAgo(3));
      await plant('fine', daysAgo(0));
      await plant('archived', daysAgo(9), status: PlantStatus.archived);
      // Never done: due [intervalDays] after its creation, i.e. today.
      await RemindersRepository(db).save(ReminderModel(
        id: 'r1',
        plantId: 'fine',
        entryType: EntryType.fertilizer,
        intervalDays: 30,
        createdAt: daysAgo(30),
      ));
    });

    tearDown(() => db.close());

    test('builds the snapshot from the database, like the agenda', () async {
      final gateway = _FakeGateway();

      await publishHomeWidgetFromDatabase(db, gateway: gateway, now: now);

      final snapshot = gateway.published.single;
      final l10n = systemL10n();
      expect(snapshot.day, today);
      expect(snapshot.rows.map((r) => r.plantId), ['late', 'due', 'fine']);
      expect(snapshot.rows.map((r) => r.status), [
        l10n.homeWidgetOverdue(2),
        l10n.homeWidgetToday,
        l10n.homeWidgetToday,
      ]);
      expect(snapshot.rows.map((r) => r.canWater), [true, true, false]);
      expect(snapshot.rows.last.emoji, EntryType.fertilizer.emoji);
      expect(snapshot.header, l10n.homeWidgetDueCount(3));
    });

    test('drops a plant once it is watered', () async {
      await PlantsRepository(db, _NoopNotifications()).irrigate('late');
      final gateway = _FakeGateway();

      await publishHomeWidgetFromDatabase(db, gateway: gateway, now: now);

      expect(
          gateway.published.single.rows.map((r) => r.plantId), ['due', 'fine']);
    });
  });

  group('HomeWidgetLink.parse', () {
    test('reads the links the widget sends', () {
      final agenda = HomeWidgetLink.parse(Uri.parse('polypodium://agenda'))!;
      expect(agenda.type, HomeWidgetLinkType.agenda);
      expect(agenda.plantId, isNull);

      final plant =
          HomeWidgetLink.parse(Uri.parse('polypodium://plant?id=a%20b'))!;
      expect(plant.type, HomeWidgetLinkType.plant);
      expect(plant.plantId, 'a b');

      final water =
          HomeWidgetLink.parse(Uri.parse('polypodium://water?id=p1'))!;
      expect(water.type, HomeWidgetLinkType.water);
      expect(water.plantId, 'p1');

      expect(HomeWidgetLink.parse(Uri.parse('polypodium://refresh'))!.type,
          HomeWidgetLinkType.refresh);
    });

    test('ignores anything else', () {
      expect(HomeWidgetLink.parse(null), isNull);
      expect(HomeWidgetLink.parse(Uri.parse('https://agenda')), isNull);
      expect(HomeWidgetLink.parse(Uri.parse('polypodium://unknown')), isNull);
      expect(HomeWidgetLink.parse(Uri.parse('polypodium://plant')), isNull);
      expect(HomeWidgetLink.parse(Uri.parse('polypodium://water?id=')), isNull);
    });
  });
}
