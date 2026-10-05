import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:polypodium/core/enums.dart';
import 'package:polypodium/features/agenda/domain/agenda_task.dart';
import 'package:polypodium/features/agenda/presentation/providers/agenda_providers.dart';
import 'package:polypodium/features/agenda/presentation/screens/agenda_screen.dart';
import 'package:polypodium/features/entries/presentation/providers/entries_providers.dart';
import 'package:polypodium/features/plants/domain/plant_model.dart';
import 'package:polypodium/features/settings/presentation/providers/settings_providers.dart';
import 'package:polypodium/features/species/domain/species_model.dart';
import 'package:polypodium/l10n/app_localizations.dart';

import '../../../helpers/accessibility.dart';

class _FakeTransparencyNotifier extends TransparencyEnabledNotifier {
  @override
  bool build() => true;
}

class _FakeEntryMutations implements EntryMutations {
  final irrigated = <List<String>>[];

  @override
  Future<void> recordIrrigation(Iterable<String> plantIds) async =>
      irrigated.add(plantIds.toList());

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

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

  AgendaTask task(String plantId, int daysRelative,
          {AgendaTaskKind kind = AgendaTaskKind.irrigation,
          EntryType type = EntryType.irrigation}) =>
      AgendaTask(
        plant: plant(plantId),
        kind: kind,
        entryType: type,
        dueDate: DateTime(today.year, today.month, today.day - daysRelative),
        daysRelative: daysRelative,
      );

  late _FakeEntryMutations mutations;

  Future<void> pump(WidgetTester tester, List<AgendaTask> tasks,
      {ThemeData? theme}) async {
    mutations = _FakeEntryMutations();
    await tester.pumpWidget(ProviderScope(
      overrides: [
        transparencyEnabledNotifierProvider
            .overrideWith(_FakeTransparencyNotifier.new),
        agendaTasksProvider.overrideWith((ref) async => tasks),
        entryMutationsProvider.overrideWithValue(mutations),
      ],
      child: MaterialApp(
        theme: theme,
        locale: const Locale('pt'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const AgendaScreen(),
      ),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('renders overdue, today and upcoming sections', (tester) async {
    await pump(tester, [
      task('Samambaia', 3),
      task('Jiboia', 0, kind: AgendaTaskKind.care, type: EntryType.fertilizer),
      task('Costela', -1),
      task('Hera', -3,
          kind: AgendaTaskKind.pesticide, type: EntryType.pesticide),
    ]);

    expect(find.text('Atrasados (1)'), findsOneWidget);
    expect(find.text('Atrasado há 3 dias'), findsOneWidget);
    expect(find.text('Hoje (1)'), findsOneWidget);
    expect(find.text('Próximos 7 dias (2)'), findsOneWidget);
    expect(find.text('Amanhã'), findsOneWidget);
    expect(find.text('Samambaia'), findsOneWidget);
    expect(find.text('Hera'), findsOneWidget);
    expect(find.text('Reaplicação de defensivo'), findsOneWidget);
    expect(find.text('Reguei'), findsNWidgets(2));
    expect(find.text('Registrar'), findsNWidgets(2));
  });

  testWidgets('shows the empty state when nothing is pending', (tester) async {
    await pump(tester, const []);

    expect(find.text('Tudo em dia! 🌿'), findsOneWidget);
    expect(find.byTooltip('Regar todas'), findsNothing);
  });

  testWidgets('"Reguei" records the irrigation of that plant', (tester) async {
    await pump(tester, [task('Samambaia', 1), task('Costela', -2)]);

    await tester.tap(find.text('Reguei').first);
    await tester.pumpAndSettle();

    expect(mutations.irrigated, [
      ['Samambaia'],
    ]);
    expect(find.text('Irrigação registrada!'), findsOneWidget);
  });

  testWidgets('"Regar todas" waters only the overdue and today tasks',
      (tester) async {
    await pump(tester, [
      task('Samambaia', 1),
      task('Jiboia', 0),
      task('Costela', -2),
      task('Hera', 0, kind: AgendaTaskKind.care, type: EntryType.pruning),
    ]);

    await tester.tap(find.byTooltip('Regar todas'));
    await tester.pumpAndSettle();

    expect(mutations.irrigated, [
      ['Samambaia', 'Jiboia'],
    ]);
    expect(find.text('Rega registrada em 2 plantas'), findsOneWidget);
  });

  group('accessibility', () {
    List<AgendaTask> tasks() => [
          task('Samambaia', 3),
          task('Jiboia', 0,
              kind: AgendaTaskKind.care, type: EntryType.fertilizer),
          task('Hera', -3,
              kind: AgendaTaskKind.pesticide, type: EntryType.pesticide),
        ];

    testWidgets('meets the tap target and labelling guidelines',
        (tester) async {
      final semantics = tester.ensureSemantics();
      await pump(tester, tasks());

      await expectTapTargetGuidelines(tester);
      // The type is read from the task label, not the emoji next to it.
      expect(find.bySemanticsLabel(emojiLabel), findsNothing);
      expect(find.bySemanticsLabel(RegExp('Fertilização')), findsOneWidget);
      semantics.dispose();
    });

    for (final (name, theme) in appThemes) {
      testWidgets('text is readable in the $name theme', (tester) async {
        final semantics = tester.ensureSemantics();
        await pump(tester, tasks(), theme: theme);
        await paintBackground(tester);
        await expectReadableText(tester);
        semantics.dispose();
      });
    }

    for (final scale in [1.5, 2.0]) {
      testWidgets('lays out without overflow at text scale $scale',
          (tester) async {
        tester.view.physicalSize = const Size(400, 1600);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        setTextScale(tester, scale);

        await pump(tester, tasks());
        expect(tester.takeException(), isNull);
        expect(find.text('Samambaia'), findsOneWidget);
      });
    }
  });
}
