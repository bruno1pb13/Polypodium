import 'package:flutter_test/flutter_test.dart';
import 'package:polypodium/core/enums.dart';
import 'package:polypodium/features/agenda/domain/agenda_task.dart';
import 'package:polypodium/features/dashboard/domain/garden_overview.dart';
import 'package:polypodium/features/entries/domain/entry_model.dart';
import 'package:polypodium/features/plants/domain/plant_model.dart';
import 'package:polypodium/features/species/domain/species_model.dart';

void main() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  DateTime daysAgo(int days, {int hour = 10}) =>
      DateTime(today.year, today.month, today.day - days, hour);

  PlantWithSpecies plant(
    String id, {
    String speciesId = 's1',
    int? wateredDaysAgo = 0,
    PlantStatus status = PlantStatus.active,
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
    List<EntryModel> conditions = const [],
  }) =>
      buildGardenOverview(
        plants: plants,
        tasks: tasks,
        conditionEntries: conditions,
      );

  test('splits due tasks from the upcoming ones', () {
    final a = plant('a');
    final o = build(
      plants: [a],
      tasks: [task(a, 2), task(a, 0), task(a, -3)],
    );

    expect(o.dueTasks, hasLength(2));
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
}
