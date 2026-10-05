import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:polypodium/core/enums.dart';
import 'package:polypodium/features/agenda/domain/agenda_task.dart';
import 'package:polypodium/features/agenda/domain/home_widget_snapshot.dart';
import 'package:polypodium/features/plants/domain/plant_model.dart';
import 'package:polypodium/features/species/domain/species_model.dart';
import 'package:polypodium/l10n/app_localizations.dart';

void main() {
  final pt = lookupAppLocalizations(const Locale('pt'));
  final en = lookupAppLocalizations(const Locale('en'));
  final now = DateTime(2026, 10, 5, 14, 30);

  AgendaTask task(
    String id,
    int daysRelative, {
    AgendaTaskKind kind = AgendaTaskKind.irrigation,
    EntryType entryType = EntryType.irrigation,
  }) =>
      AgendaTask(
        plant: PlantWithSpecies(
          plant: PlantModel(
            id: id,
            speciesId: 's1',
            nickname: 'Plant $id',
            soilId: 'loamy',
            acquisitionDate: DateTime(2024, 1, 1),
            createdAt: DateTime(2024, 1, 1),
          ),
          species: SpeciesModel(
            id: 's1',
            popularName: 'Fern',
            defaultIrrigationFrequencyDays: 3,
            scientificName: 'Polypodium',
            recommendedSoilIds: const [],
            createdAt: DateTime(2024, 1, 1),
          ),
        ),
        kind: kind,
        entryType: entryType,
        dueDate: DateTime(2026, 10, 5 - daysRelative),
        daysRelative: daysRelative,
      );

  test('lists only due tasks, in agenda order, with localized labels', () {
    final snapshot = buildHomeWidgetSnapshot([
      task('a', 3),
      task('b', 0,
          kind: AgendaTaskKind.pesticide, entryType: EntryType.pesticide),
      task('c', 0, kind: AgendaTaskKind.care, entryType: EntryType.fertilizer),
      task('d', -1),
    ], pt, now: now);

    expect(snapshot.dueCount, 3);
    expect(snapshot.header, '3 para hoje');
    expect(snapshot.rows.map((r) => r.name), ['Plant a', 'Plant b', 'Plant c']);
    expect(
        snapshot.rows.map((r) => r.status), ['atrasado 3 d', 'hoje', 'hoje']);
    expect(snapshot.rows.map((r) => r.emoji), [
      EntryType.irrigation.emoji,
      EntryType.pesticide.emoji,
      EntryType.fertilizer.emoji,
    ]);
    expect(snapshot.rows.map((r) => r.canWater), [true, false, false]);
    expect(snapshot.rows.first.plantId, 'a');
    expect(snapshot.more, isEmpty);
  });

  test('caps the rows and counts the rest', () {
    final snapshot = buildHomeWidgetSnapshot(
        [for (var i = 0; i < 8; i++) task('$i', 8 - i)], en,
        now: now);

    expect(snapshot.rows, hasLength(homeWidgetMaxRows));
    expect(snapshot.rows.map((r) => r.plantId), ['0', '1', '2', '3', '4']);
    expect(snapshot.header, '8 due today');
    expect(snapshot.more, '+3 more');
  });

  test('says all caught up when nothing is due', () {
    final snapshot = buildHomeWidgetSnapshot([task('a', -2)], pt, now: now);

    expect(snapshot.dueCount, 0);
    expect(snapshot.rows, isEmpty);
    expect(snapshot.header, pt.agendaAllCaughtUp);
    expect(snapshot.more, isEmpty);
  });

  test('serializes the day and the rows for the native side', () {
    final json = buildHomeWidgetSnapshot([task('a', 1)], en,
            now: DateTime(2026, 3, 7, 23, 59))
        .toJson();

    expect(json['day'], '2026-03-07');
    expect(json['count'], 1);
    expect(json['header'], '1 due today');
    expect(json['rows'], [
      {
        'emoji': EntryType.irrigation.emoji,
        'name': 'Plant a',
        'status': '1 d late',
        'plantId': 'a',
        'water': true,
      },
    ]);
    expect(json['more'], '');
  });
}
