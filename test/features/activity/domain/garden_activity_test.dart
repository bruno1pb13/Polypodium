import 'package:flutter_test/flutter_test.dart';
import 'package:polypodium/core/enums.dart';
import 'package:polypodium/features/activity/domain/garden_activity.dart';
import 'package:polypodium/features/entries/domain/entry_model.dart';
import 'package:polypodium/features/plants/domain/plant_model.dart';
import 'package:polypodium/features/species/domain/species_model.dart';

void main() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  DateTime daysAgo(int days, {int hour = 10}) =>
      DateTime(today.year, today.month, today.day - days, hour);

  PlantWithSpecies plant(String id) => PlantWithSpecies(
        plant: PlantModel(
          id: id,
          speciesId: 's1',
          nickname: id,
          soilId: 'loamy',
          acquisitionDate: DateTime(2024, 1, 1),
          createdAt: DateTime(2024, 1, 1),
        ),
        species: SpeciesModel(
          id: 's1',
          popularName: 'Fern',
          scientificName: 'Polypodium',
          defaultIrrigationFrequencyDays: 3,
          recommendedSoilIds: const [],
          createdAt: DateTime(2024, 1, 1),
        ),
      );

  var nextId = 0;
  EntryModel entry(String plantId, EntryType type, DateTime date) => EntryModel(
        id: 'e${nextId++}',
        plantId: plantId,
        date: date,
        type: type,
        createdAt: date,
      );

  GardenActivity build(List<EntryModel> entries) => buildGardenActivity(
        plants: [plant('a')],
        entries: entries,
        now: now,
      );

  test('charts the last days, waterings apart from other care', () {
    final activity = build([
      entry('a', EntryType.fertilizer, daysAgo(0, hour: 9)),
      entry('a', EntryType.irrigation, daysAgo(0, hour: 8)),
      entry('a', EntryType.pruning, daysAgo(2)),
      entry('a', EntryType.irrigation, daysAgo(20)),
    ]);

    expect(activity.chart, hasLength(chartDays));
    expect(activity.chart.first.day, daysAgo(chartDays - 1, hour: 0));
    expect(activity.chart.last.day, today);
    expect(activity.chart.last.irrigation, 1);
    expect(activity.chart.last.care, 1);
    expect(activity.chart[chartDays - 3].care, 1);
  });

  test('groups every entry by day, newest first, skipping unknown plants', () {
    final activity = build([
      entry('a', EntryType.fertilizer, daysAgo(0, hour: 9)),
      entry('a', EntryType.irrigation, daysAgo(0, hour: 8)),
      entry('gone', EntryType.irrigation, daysAgo(1)),
      entry('a', EntryType.irrigation, daysAgo(40)),
    ]);

    expect(activity.days.map((d) => d.day), [today, daysAgo(40, hour: 0)]);
    expect(activity.days.first.entries.map((e) => e.entry.type),
        [EntryType.fertilizer, EntryType.irrigation]);
  });

  test('counts the streak of days with entries', () {
    expect(
      build([
        entry('a', EntryType.irrigation, daysAgo(0)),
        entry('a', EntryType.irrigation, daysAgo(1)),
        entry('a', EntryType.irrigation, daysAgo(2)),
        entry('a', EntryType.irrigation, daysAgo(4)),
      ]).streakDays,
      3,
    );
    // Nothing logged today yet: the streak up to yesterday still counts.
    expect(
      build([
        entry('a', EntryType.irrigation, daysAgo(1)),
        entry('a', EntryType.irrigation, daysAgo(2)),
      ]).streakDays,
      2,
    );
    expect(build(const []).streakDays, 0);
  });
}
