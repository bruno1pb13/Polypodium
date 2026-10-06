import 'package:flutter_test/flutter_test.dart';
import 'package:polypodium/core/enums.dart';
import 'package:polypodium/features/agenda/domain/agenda_task.dart';
import 'package:polypodium/features/dashboard/domain/garden_overview.dart';
import 'package:polypodium/features/entries/domain/entry_model.dart';
import 'package:polypodium/features/locations/domain/location_model.dart';
import 'package:polypodium/features/plants/domain/plant_model.dart';
import 'package:polypodium/features/species/domain/species_model.dart';

void main() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  DateTime daysAgo(int days, {int hour = 10}) =>
      DateTime(today.year, today.month, today.day - days, hour);

  LocationModel location(String name) => LocationModel(
        id: 'loc-$name',
        name: name,
        createdAt: DateTime(2024, 1, 1),
      );

  PlantWithSpecies plant(
    String id, {
    String speciesId = 's1',
    int? wateredDaysAgo = 0,
    PlantStatus status = PlantStatus.active,
    LocationModel? at,
  }) =>
      PlantWithSpecies(
        plant: PlantModel(
          id: id,
          speciesId: speciesId,
          nickname: id,
          soilId: 'loamy',
          acquisitionDate: DateTime(2024, 1, 1),
          lastIrrigatedAt:
              wateredDaysAgo == null ? null : daysAgo(wateredDaysAgo),
          status: status,
          locationId: at?.id,
          createdAt: DateTime(2024, 1, 1),
        ),
        species: SpeciesModel(
          id: speciesId,
          popularName: 'Fern',
          scientificName: 'Polypodium',
          defaultIrrigationFrequencyDays: 3,
          recommendedSoilIds: const [],
          createdAt: DateTime(2024, 1, 1),
        ),
        location: at,
      );

  var nextId = 0;
  EntryModel entry(String plantId, EntryType type, DateTime date,
          {double? value}) =>
      EntryModel(
        id: 'e${nextId++}',
        plantId: plantId,
        date: date,
        type: type,
        numericValue: value,
        createdAt: date,
      );

  AgendaTask task(PlantWithSpecies p, int daysRelative) => AgendaTask(
        plant: p,
        kind: AgendaTaskKind.irrigation,
        entryType: EntryType.irrigation,
        dueDate: DateTime(today.year, today.month, today.day - daysRelative),
        daysRelative: daysRelative,
      );

  GardenOverview build({
    List<PlantWithSpecies> plants = const [],
    List<AgendaTask> tasks = const [],
    List<EntryModel> recent = const [],
    List<EntryModel> conditions = const [],
  }) =>
      buildGardenOverview(
        plants: plants,
        tasks: tasks,
        recentEntries: recent,
        conditionEntries: conditions,
        now: now,
      );

  test('counts only active plants, their species and locations', () {
    final varanda = location('Varanda');
    final o = build(plants: [
      plant('a', at: varanda),
      plant('b', speciesId: 's2', at: varanda),
      plant('c', speciesId: 's3', status: PlantStatus.archived),
    ]);

    expect(o.activeCount, 2);
    expect(o.speciesCount, 2);
    expect(o.locationCount, 1);
  });

  test('splits due tasks from the upcoming ones', () {
    final a = plant('a');
    final o = build(
      plants: [a],
      tasks: [task(a, 2), task(a, 0), task(a, -3)],
    );

    expect(o.dueTasks, hasLength(2));
    expect(o.overdueCount, 1);
    expect(o.upcomingCount, 1);
  });

  test('a plant is healthy without pending water, pests or chlorosis', () {
    final o = build(
      plants: [
        plant('ok'),
        plant('thirsty', wateredDaysAgo: 5),
        plant('bugs'),
        plant('cured'),
        plant('yellow'),
      ],
      // Newest first, as the repository returns them.
      conditions: [
        entry('cured', EntryType.pest, daysAgo(1), value: 0),
        entry('bugs', EntryType.pest, daysAgo(2), value: 2),
        entry('cured', EntryType.pest, daysAgo(5), value: 3),
        entry('yellow', EntryType.chlorosis, daysAgo(3)),
      ],
    );

    expect(o.needsWaterCount, 1);
    expect(o.pestCount, 1);
    expect(o.chlorosisCount, 1);
    expect(o.healthyCount, 2);
    expect(o.healthyRatio, closeTo(0.4, 1e-9));
    expect(o.spotlight.take(3).map((p) => p.plant.id),
        unorderedEquals(['thirsty', 'bugs', 'yellow']));
  });

  test('an empty garden counts as fully healthy', () {
    expect(build().healthyRatio, 1);
  });

  test('buckets the activity per day and counts the streak', () {
    final a = plant('a');
    final o = build(plants: [
      a
    ], recent: [
      entry('a', EntryType.irrigation, daysAgo(0, hour: 8)),
      entry('a', EntryType.fertilizer, daysAgo(0, hour: 9)),
      entry('a', EntryType.irrigation, daysAgo(1)),
      entry('a', EntryType.pruning, daysAgo(2)),
      entry('a', EntryType.irrigation, daysAgo(4)),
      entry('a', EntryType.irrigation, daysAgo(20)),
      entry('gone', EntryType.irrigation, daysAgo(0)),
    ]);

    expect(o.activity, hasLength(chartDays));
    expect(o.activity.last.day, today);
    expect(o.activity.last.irrigation, 1);
    expect(o.activity.last.care, 1);
    expect(o.activity[chartDays - 3].care, 1);
    expect(o.entriesInWindow, 6);
    expect(o.streakDays, 3);
    expect(o.recent.map((r) => r.entry.plantId), everyElement('a'));
    expect(o.recent, hasLength(recentEntriesShown));
  });

  test('the streak still counts while nothing was logged today', () {
    final o = build(plants: [
      plant('a')
    ], recent: [
      entry('a', EntryType.irrigation, daysAgo(1)),
      entry('a', EntryType.irrigation, daysAgo(2)),
    ]);

    expect(o.streakDays, 2);
  });

  test('lists locations by plant count, plants without one last', () {
    final varanda = location('Varanda');
    final sala = location('Sala');
    final o = build(plants: [
      plant('a'),
      plant('b'),
      plant('c'),
      plant('d', at: sala),
      plant('e', at: varanda),
      plant('f', at: varanda),
    ]);

    expect(o.byLocation, [
      (name: 'Varanda', count: 2),
      (name: 'Sala', count: 1),
      (name: null, count: 3),
    ]);
  });
}
