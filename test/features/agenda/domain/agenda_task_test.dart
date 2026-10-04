import 'package:flutter_test/flutter_test.dart';
import 'package:polypodium/core/enums.dart';
import 'package:polypodium/features/agenda/domain/agenda_task.dart';
import 'package:polypodium/features/plants/domain/plant_model.dart';
import 'package:polypodium/features/reminders/domain/reminder_model.dart';
import 'package:polypodium/features/species/domain/species_model.dart';

void main() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  DateTime daysAgo(int days, [int hour = 0, int minute = 0]) =>
      DateTime(today.year, today.month, today.day - days, hour, minute);

  PlantWithSpecies plant(
    String id, {
    int? frequency = 3,
    DateTime? lastIrrigatedAt,
    DateTime? lastPesticideAppliedAt,
    int? pesticideReapplicationDays,
    PlantStatus status = PlantStatus.active,
  }) =>
      PlantWithSpecies(
        plant: PlantModel(
          id: id,
          speciesId: 's1',
          nickname: id,
          soilId: 'loamy',
          acquisitionDate: DateTime(2024, 1, 1),
          createdAt: DateTime(2024, 1, 1),
          lastIrrigatedAt: lastIrrigatedAt,
          lastPesticideAppliedAt: lastPesticideAppliedAt,
          pesticideReapplicationDays: pesticideReapplicationDays,
          status: status,
        ),
        species: SpeciesModel(
          id: 's1',
          popularName: 'Fern',
          scientificName: 'Polypodium',
          defaultIrrigationFrequencyDays: frequency,
          recommendedSoilIds: const [],
          createdAt: DateTime(2024, 1, 1),
        ),
      );

  ReminderStatus reminder(
    String plantId,
    EntryType type,
    int intervalDays, {
    required DateTime lastDoneAt,
    bool enabled = true,
  }) =>
      ReminderStatus(
        reminder: ReminderModel(
          id: '$plantId-${type.name}',
          plantId: plantId,
          entryType: type,
          intervalDays: intervalDays,
          enabled: enabled,
          createdAt: DateTime(2024, 1, 1),
        ),
        lastDoneAt: lastDoneAt,
      );

  List<AgendaTask> build(List<PlantWithSpecies> plants,
          [List<ReminderStatus> reminders = const []]) =>
      buildAgendaTasks(plants: plants, reminders: reminders);

  test('buckets irrigation into overdue, today and upcoming', () {
    final tasks = build([
      plant('late', lastIrrigatedAt: daysAgo(5)),
      plant('due', lastIrrigatedAt: daysAgo(3)),
      plant('soon', lastIrrigatedAt: daysAgo(1)),
    ]);

    expect(tasks.map((t) => t.plant.plant.id), ['late', 'due', 'soon']);
    expect(tasks.map((t) => t.bucket), [
      AgendaBucket.overdue,
      AgendaBucket.today,
      AgendaBucket.upcoming,
    ]);
    expect(tasks[0].daysRelative, 2);
    expect(tasks[0].dueDate, daysAgo(2));
    expect(tasks[1].dueDate, today);
    expect(tasks[2].daysRelative, -2);
    expect(tasks[2].dueDate, daysAgo(-2));
  });

  test('counts calendar days, not 24 h blocks', () {
    // Watered late yesterday with a daily frequency: due today, even though
    // less than 24 h have passed.
    final tasks = build([
      plant('p', frequency: 1, lastIrrigatedAt: daysAgo(1, 23, 59)),
    ]);
    expect(tasks.single.bucket, AgendaBucket.today);

    final earlyToday = build([
      plant('p', frequency: 1, lastIrrigatedAt: daysAgo(0, 0, 1)),
    ]);
    expect(earlyToday.single.daysRelative, -1);
    expect(earlyToday.single.dueDate, daysAgo(-1));
  });

  test('never-watered plant with a frequency is due today', () {
    final tasks = build([plant('p')]);
    expect(tasks.single.kind, AgendaTaskKind.irrigation);
    expect(tasks.single.bucket, AgendaBucket.today);
  });

  test('leaves out tasks beyond the horizon', () {
    final tasks = build([
      plant('edge', frequency: 8, lastIrrigatedAt: daysAgo(1)),
      plant('far', frequency: 9, lastIrrigatedAt: daysAgo(1)),
    ]);
    expect(tasks.single.plant.plant.id, 'edge');
    expect(tasks.single.daysRelative, -agendaHorizonDays);
  });

  test('excludes plants without a frequency and inactive plants', () {
    final tasks = build([
      plant('noFreq', frequency: null, lastIrrigatedAt: daysAgo(30)),
      plant('archived',
          status: PlantStatus.archived, lastIrrigatedAt: daysAgo(30)),
      plant('dead', status: PlantStatus.dead, lastIrrigatedAt: daysAgo(30)),
    ], [
      reminder('archived', EntryType.fertilizer, 10, lastDoneAt: daysAgo(30)),
    ]);
    expect(tasks, isEmpty);
  });

  test('adds pesticide reapplication tasks', () {
    final tasks = build([
      plant('p',
          frequency: null,
          lastPesticideAppliedAt: daysAgo(10),
          pesticideReapplicationDays: 7),
    ]);
    expect(tasks.single.kind, AgendaTaskKind.pesticide);
    expect(tasks.single.entryType, EntryType.pesticide);
    expect(tasks.single.daysRelative, 3);
  });

  test('adds enabled reminders only, for known active plants', () {
    final tasks = build([
      plant('p', frequency: null),
    ], [
      reminder('p', EntryType.fertilizer, 10, lastDoneAt: daysAgo(10)),
      reminder('p', EntryType.pruning, 10,
          lastDoneAt: daysAgo(12), enabled: false),
      reminder('gone', EntryType.observation, 1, lastDoneAt: daysAgo(5)),
    ]);
    expect(tasks.single.kind, AgendaTaskKind.care);
    expect(tasks.single.entryType, EntryType.fertilizer);
    expect(tasks.single.bucket, AgendaBucket.today);
    expect(tasks.single.dueDate, today);
  });

  test('sorts by days relative, then kind, then nickname', () {
    final tasks = build([
      plant('b', lastIrrigatedAt: daysAgo(3)),
      plant('A', lastIrrigatedAt: daysAgo(3)),
      plant('c',
          frequency: null,
          lastPesticideAppliedAt: daysAgo(5),
          pesticideReapplicationDays: 5),
    ], [
      reminder('A', EntryType.pruning, 4, lastDoneAt: daysAgo(10)),
      reminder('b', EntryType.fertilizer, 4, lastDoneAt: daysAgo(4)),
    ]);

    expect(
      tasks.map((t) => '${t.plant.plant.id}:${t.entryType.name}'),
      [
        'A:pruning', // 6 days overdue
        'A:irrigation', // due today, irrigation first
        'b:irrigation',
        'c:pesticide',
        'b:fertilizer',
      ],
    );
  });
}
