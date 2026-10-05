import 'dart:ui';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:polypodium/core/enums.dart';
import 'package:polypodium/features/agenda/data/home_widget_service.dart';
import 'package:polypodium/features/agenda/domain/agenda_task.dart';
import 'package:polypodium/features/agenda/domain/home_widget_snapshot.dart';
import 'package:polypodium/features/agenda/presentation/providers/agenda_providers.dart';
import 'package:polypodium/features/agenda/presentation/providers/home_widget_providers.dart';
import 'package:polypodium/features/plants/domain/plant_model.dart';
import 'package:polypodium/features/species/domain/species_model.dart';
import 'package:polypodium/l10n/app_localizations.dart';

class _FakeGateway implements HomeWidgetGateway {
  final published = <HomeWidgetSnapshot>[];

  @override
  Future<void> publish(HomeWidgetSnapshot snapshot) async =>
      published.add(snapshot);
}

class _Tasks extends Notifier<List<AgendaTask>> {
  @override
  List<AgendaTask> build() => [];

  void set(List<AgendaTask> tasks) => state = tasks;
}

final _tasksSource = NotifierProvider<_Tasks, List<AgendaTask>>(_Tasks.new);

void main() {
  final en = lookupAppLocalizations(const Locale('en'));

  AgendaTask task(String id, int daysRelative) => AgendaTask(
        plant: PlantWithSpecies(
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
            defaultIrrigationFrequencyDays: 3,
            scientificName: 'Polypodium',
            recommendedSoilIds: const [],
            createdAt: DateTime(2024, 1, 1),
          ),
        ),
        kind: AgendaTaskKind.irrigation,
        entryType: EntryType.irrigation,
        dueDate: DateTime(2026, 10, 5 - daysRelative),
        daysRelative: daysRelative,
      );

  test('HomeWidgetSync publishes the last of a burst once', () {
    fakeAsync((async) {
      final gateway = _FakeGateway();
      final sync = HomeWidgetSync(gateway,
          l10n: () => en, now: () => DateTime(2026, 10, 5, 8));

      sync.schedule([task('a', 0)]);
      async.elapse(const Duration(milliseconds: 500));
      sync.schedule([task('a', 0), task('b', 1)]);
      async.elapse(const Duration(milliseconds: 999));
      expect(gateway.published, isEmpty);

      async.elapse(const Duration(milliseconds: 1));
      expect(gateway.published, hasLength(1));
      expect(gateway.published.single.dueCount, 2);
      expect(gateway.published.single.dayKey, '2026-10-05');

      sync.schedule([]);
      sync.dispose();
      async.elapse(const Duration(seconds: 5));
      expect(gateway.published, hasLength(1));
    });
  });

  test('the provider republishes whenever the agenda changes', () {
    fakeAsync((async) {
      final gateway = _FakeGateway();
      final container = ProviderContainer(overrides: [
        homeWidgetGatewayProvider.overrideWithValue(gateway),
        agendaTasksProvider
            .overrideWith((ref) async => ref.watch(_tasksSource)),
      ]);
      addTearDown(container.dispose);

      container.listen(homeWidgetSyncProvider, (_, __) {});
      async.elapse(const Duration(seconds: 2));
      expect(gateway.published, hasLength(1));
      expect(gateway.published.last.dueCount, 0);

      // E.g. a plant watered, or a workspace switch: a new agenda.
      container.read(_tasksSource.notifier).set([task('a', 2), task('b', -1)]);
      async.elapse(const Duration(seconds: 2));
      expect(gateway.published, hasLength(2));
      expect(gateway.published.last.dueCount, 1);
      expect(gateway.published.last.rows.single.plantId, 'a');
    });
  });
}
