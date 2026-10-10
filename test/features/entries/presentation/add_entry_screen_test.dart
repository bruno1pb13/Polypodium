import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:polypodium/core/enums.dart';
import 'package:polypodium/core/storage/photo_storage.dart';
import 'package:polypodium/core/storage/photo_storage_provider.dart';
import 'package:polypodium/features/defensivos/domain/defensivo_model.dart';
import 'package:polypodium/features/defensivos/presentation/providers/defensivos_search_providers.dart';
import 'package:polypodium/features/defensivos/presentation/widgets/defensivo_selection_field.dart';
import 'package:polypodium/features/entries/domain/entry_details.dart';
import 'package:polypodium/features/entries/domain/entry_model.dart';
import 'package:polypodium/features/entries/domain/carencia.dart';
import 'package:polypodium/features/entries/presentation/providers/carencia_providers.dart';
import 'package:polypodium/features/entries/presentation/providers/entries_providers.dart';
import 'package:polypodium/features/entries/presentation/screens/add_entry_screen.dart';
import 'package:polypodium/features/soils/domain/soil_model.dart';
import 'package:polypodium/features/soils/presentation/providers/soils_search_providers.dart';
import 'package:polypodium/features/reminders/domain/reminder_model.dart';
import 'package:polypodium/features/reminders/presentation/providers/reminders_providers.dart';
import 'package:polypodium/l10n/app_localizations.dart';

import '../../../helpers/accessibility.dart';

class _FakeEntryMutations implements EntryMutations {
  final created = <List<EntryModel>>[];
  final reminderIntervals = <int?>[];

  @override
  Future<void> createMany(List<EntryModel> entries,
      {int? reminderIntervalDays}) async {
    created.add(entries);
    reminderIntervals.add(reminderIntervalDays);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeCarenciaChecker implements CarenciaChecker {
  _FakeCarenciaChecker(this.affected);
  final List<PlantCarencia> affected;
  final checked = <List<String>>[];

  @override
  Future<List<PlantCarencia>> plantsInCarencia(
      List<String> plantIds, DateTime day) async {
    checked.add(plantIds);
    return affected.where((p) => plantIds.contains(p.plantId)).toList();
  }
}

void main() {
  final defensivos = [
    DefensivoModel(
        id: 'd1', name: 'Óleo de Neem', createdAt: DateTime(2026, 1, 1)),
    DefensivoModel(
        id: 'd2',
        name: 'Calda Bordalesa',
        carenciaDays: 7,
        createdAt: DateTime(2026, 1, 1)),
  ];

  final soils = [
    SoilModel(
        id: 'soil1', name: 'Substrato p/ suculentas',
        createdAt: DateTime(2026, 1, 1)),
  ];

  late _FakeEntryMutations mutations;
  late _FakeCarenciaChecker carenciaChecker;

  // Pushes [screen] over a launcher route so the Navigator.pop on save has
  // somewhere to go back to.
  Future<void> pump(WidgetTester tester, AddEntryScreen screen,
      {Size size = const Size(800, 3000),
      ThemeData? theme,
      List<PlantCarencia> inCarencia = const [],
      List<ReminderStatus> reminders = const []}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    // Start from scratch when a test opens the screen more than once.
    await tester.pumpWidget(const SizedBox());
    mutations = _FakeEntryMutations();
    carenciaChecker = _FakeCarenciaChecker(inCarencia);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        entryMutationsProvider.overrideWithValue(mutations),
        for (final id in ['p1', 'p2'])
          plantRemindersProvider(id)
              .overrideWith((ref) => Stream.value(reminders)),
        carenciaCheckerProvider.overrideWithValue(carenciaChecker),
        photoStorageProvider
            .overrideWithValue(PhotoStorage(baseDirName: 'test_photos')),
        filteredSortedDefensivosProvider
            .overrideWith((ref) async => defensivos),
        filteredSortedSoilsProvider.overrideWith((ref) async => soils),
      ],
      child: MaterialApp(
        theme: theme,
        locale: const Locale('pt'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => screen),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  Future<void> selectType(WidgetTester tester, EntryType type, String label) =>
      tester.tap(find.text('${type.emoji} $label')).then((_) => tester.pump());

  Future<void> save(WidgetTester tester) async {
    await tester.tap(find.text('Salvar registro'));
    await tester.pumpAndSettle();
  }

  Finder field(String label) => find.widgetWithText(TextField, label);

  Future<void> pickDefensivo(WidgetTester tester, int row, String name) async {
    await tester.tap(find.byType(DefensivoSelectionField).at(row));
    await tester.pumpAndSettle();
    await tester.tap(find.text(name).last);
    await tester.pumpAndSettle();
  }

  testWidgets('defaults to observation and honors initialType', (tester) async {
    await pump(tester, AddEntryScreen(plantId: 'p1'));
    expect(
      tester
          .widget<ChoiceChip>(find.widgetWithText(
              ChoiceChip, '${EntryType.observation.emoji} Observação'))
          .selected,
      isTrue,
    );

    await pump(
      tester,
      AddEntryScreen(plantId: 'p1', initialType: EntryType.pruning),
    );
    expect(
      tester
          .widget<ChoiceChip>(find.widgetWithText(
              ChoiceChip, '${EntryType.pruning.emoji} Poda'))
          .selected,
      isTrue,
    );
    expect(find.text('Formação'), findsOneWidget);
  });

  testWidgets('irrigation stores the intensity as numericValue',
      (tester) async {
    await pump(tester, AddEntryScreen(plantId: 'p1'));
    await selectType(tester, EntryType.irrigation, 'Irrigação');
    await tester.tap(find.text('Intensa'));
    await tester.pump();
    await tester.enterText(find.byType(TextField).last, '  Regada à tarde  ');
    await save(tester);

    expect(mutations.created, hasLength(1));
    final entry = mutations.created.single.single;
    expect(entry.plantId, 'p1');
    expect(entry.type, EntryType.irrigation);
    expect(entry.numericValue, 3);
    expect(entry.extraData, isNull);
    expect(entry.note, 'Regada à tarde');
    expect(entry.photoPath, isNull);
    expect(find.byType(AddEntryScreen), findsNothing);
  });

  testWidgets('fertilizer stores every named product row', (tester) async {
    await pump(tester, AddEntryScreen(plantId: 'p1'));
    await selectType(tester, EntryType.fertilizer, 'Fertilização');

    await tester.enterText(field('Produto '), 'NPK 10-10-10');
    await tester.enterText(field('Dose'), '5,5');
    await tester.tap(find.text('Adicionar produto'));
    await tester.pump();
    await tester.enterText(field('Produto 2'), ' Húmus ');
    // A row without a name is dropped.
    await tester.tap(find.text('Adicionar produto'));
    await tester.pump();
    await tester.enterText(field('Dose').at(2), '3');
    await save(tester);

    final entry = mutations.created.single.single;
    expect(entry.type, EntryType.fertilizer);
    expect(entry.numericValue, isNull);
    expect(entry.note, isNull);
    expect(
      entry.extraData,
      '{"products":[{"name":"NPK 10-10-10","dose":5.5},{"name":"Húmus"}]}',
    );
  });

  testWidgets('pesticide stores the picked defensivos and the recurrence',
      (tester) async {
    await pump(tester, AddEntryScreen(plantId: 'p1'));
    await selectType(tester, EntryType.pesticide, 'Defensivos');

    await pickDefensivo(tester, 0, 'Óleo de Neem');
    await tester.enterText(field('Dose/Quantidade'), ' 5 ml/L ');
    await tester.tap(find.text('Adicionar defensivo'));
    await tester.pump();
    await pickDefensivo(tester, 1, 'Calda Bordalesa');
    await tester.enterText(field('Repetir aplicação em (opcional)'), '14,6');
    await save(tester);

    final entry = mutations.created.single.single;
    expect(entry.type, EntryType.pesticide);
    expect(entry.numericValue, isNull);
    expect(
      entry.extraData,
      '{"products":[{"defensivoId":"d1","name":"Óleo de Neem","dose":"5 ml/L"},'
      // The carência is copied from the catalog.
      '{"defensivoId":"d2","name":"Calda Bordalesa","carenciaDays":7}],'
      '"recurrenceDays":15}',
    );
  });

  testWidgets('repotting stores the pot and the new soil', (tester) async {
    await pump(tester, AddEntryScreen(plantId: 'p1'));
    await selectType(tester, EntryType.repotting, 'Replantio');

    await tester.enterText(field('Diâmetro do vaso'), '14,5');
    await tester.tap(find.text('Barro'));
    await tester.pump();
    await tester.tap(find.text('Novo solo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Substrato p/ suculentas').last);
    await tester.pumpAndSettle();
    expect(find.text('Substrato p/ suculentas'), findsOneWidget);
    await tester.enterText(find.byType(TextField).last, 'Raízes enoveladas');
    await save(tester);

    final entry = mutations.created.single.single;
    expect(entry.type, EntryType.repotting);
    expect(entry.numericValue, isNull);
    expect(entry.note, 'Raízes enoveladas');
    expect(
      entry.extraData,
      '{"potDiameterCm":14.5,"potMaterial":"clay","newSoilId":"soil1",'
      '"newSoilName":"Substrato p/ suculentas"}',
    );
    expect(entry.details, isA<RepottingDetails>());
  });

  testWidgets('repotting without details stores no extraData',
      (tester) async {
    await pump(tester,
        AddEntryScreen(plantId: 'p1', initialType: EntryType.repotting));

    // A picked soil can be dropped again.
    await tester.tap(find.text('Novo solo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Substrato p/ suculentas').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Manter o solo atual'));
    await tester.pump();
    expect(find.byTooltip('Manter o solo atual'), findsNothing);
    await save(tester);

    final entry = mutations.created.single.single;
    expect(entry.type, EntryType.repotting);
    expect(entry.extraData, isNull);
  });

  testWidgets('pest stores the type and the severity', (tester) async {
    await pump(tester, AddEntryScreen(plantId: 'p1'));
    await selectType(tester, EntryType.pest, 'Parasitas');

    await tester.enterText(field('Tipo de parasita *'), ' Cochonilha ');
    await tester.tap(find.text('Severa'));
    await tester.pump();
    await save(tester);

    final entry = mutations.created.single.single;
    expect(entry.type, EntryType.pest);
    expect(entry.numericValue, 3);
    expect(entry.extraData, '{"pestType":"Cochonilha"}');
  });

  testWidgets('pruning and observation store reason and health score',
      (tester) async {
    await pump(tester, AddEntryScreen(plantId: 'p1'));
    await tester.tap(find.text('4'));
    await tester.pump();
    expect(find.text('Boa'), findsOneWidget);
    await save(tester);

    var entry = mutations.created.single.single;
    expect(entry.type, EntryType.observation);
    expect(entry.numericValue, 4);
    expect(entry.extraData, isNull);

    await pump(
      tester,
      AddEntryScreen(plantId: 'p1', initialType: EntryType.pruning),
    );
    await tester.tap(find.text('Formação'));
    await tester.pump();
    await save(tester);

    entry = mutations.created.single.single;
    expect(entry.type, EntryType.pruning);
    expect(entry.numericValue, isNull);
    expect(entry.extraData, '{"reason":"formacao"}');
  });

  testWidgets('height and chlorosis store their numeric values',
      (tester) async {
    await pump(
      tester,
      AddEntryScreen(plantId: 'p1', initialType: EntryType.height),
    );
    await tester.enterText(field('Altura em cm *'), '42,5');
    await save(tester);
    expect(mutations.created.single.single.numericValue, 42.5);
    expect(mutations.created.single.single.type, EntryType.height);

    await pump(
      tester,
      AddEntryScreen(plantId: 'p1', initialType: EntryType.chlorosis),
    );
    await tester.tap(find.text('Moderada'));
    await tester.pump();
    await save(tester);
    expect(mutations.created.single.single.numericValue, 2);
    expect(mutations.created.single.single.type, EntryType.chlorosis);
  });

  testWidgets('required fields block saving and show their errors',
      (tester) async {
    await pump(
      tester,
      AddEntryScreen(plantId: 'p1', initialType: EntryType.pest),
    );
    await save(tester);
    expect(find.text('Informe o tipo de parasita'), findsOneWidget);
    expect(mutations.created, isEmpty);

    // Switching types clears the errors.
    await selectType(tester, EntryType.height, 'Altura');
    expect(find.text('Informe uma altura em cm válida'), findsNothing);
    await tester.enterText(field('Altura em cm *'), '0');
    await save(tester);
    expect(find.text('Informe uma altura em cm válida'), findsOneWidget);
    expect(mutations.created, isEmpty);

    await selectType(tester, EntryType.pesticide, 'Defensivos');
    await save(tester);
    expect(find.text('Selecione um defensivo'), findsOneWidget);
    expect(mutations.created, isEmpty);

    // Fixing the field clears its error as soon as it is typed.
    await selectType(tester, EntryType.pest, 'Parasitas');
    await save(tester);
    expect(find.text('Informe o tipo de parasita'), findsOneWidget);
    await tester.enterText(field('Tipo de parasita *'), 'Pulgão');
    await tester.pump();
    expect(find.text('Informe o tipo de parasita'), findsNothing);
    await save(tester);
    expect(mutations.created.single.single.extraData, '{"pestType":"Pulgão"}');
  });

  testWidgets('bulk mode creates one entry per plant', (tester) async {
    await pump(
      tester,
      const AddEntryScreen.bulk(
        plantIds: ['p1', 'p2'],
        initialType: EntryType.irrigation,
      ),
    );
    expect(find.text('Novo registro (2 plantas)'), findsOneWidget);
    await tester.tap(find.text('Moderada'));
    await tester.pump();
    await tester.tap(find.text('Salvar para 2 plantas'));
    await tester.pumpAndSettle();

    final entries = mutations.created.single;
    expect(entries.map((e) => e.plantId), ['p1', 'p2']);
    expect(entries.map((e) => e.numericValue), [2, 2]);
    expect(entries.map((e) => e.type).toSet(), {EntryType.irrigation});
    expect(entries[0].id, isNot(entries[1].id));
  });

  group('entry for a pot', () {
    testWidgets('offers only the pot-compatible types, with the given title',
        (tester) async {
      await pump(
        tester,
        const AddEntryScreen.bulk(
          plantIds: ['p1', 'p2'],
          initialType: EntryType.height,
          allowedTypes: potCompatibleEntryTypes,
          title: 'Registro no vaso Vaso azul — 2 plantas',
        ),
      );

      expect(find.text('Registro no vaso Vaso azul — 2 plantas'),
          findsOneWidget);
      for (final type in EntryType.values) {
        final chip = find.text(
            '${type.emoji} ${type.label(lookupAppLocalizations(const Locale('pt')))}');
        final offered = type.isPotCompatible &&
            type != EntryType.other &&
            type != EntryType.history;
        expect(chip, offered ? findsWidgets : findsNothing,
            reason: type.name);
      }
      // A disallowed initial type falls back to observation.
      await tester.tap(find.text('Salvar para 2 plantas'));
      await tester.pumpAndSettle();
      expect(mutations.created.single.map((e) => e.type).toSet(),
          {EntryType.observation});
    });

    testWidgets('creates one entry per plant in the pot when saved',
        (tester) async {
      final inPot = ['p1'];
      await pump(
        tester,
        AddEntryScreen.bulk(
          plantIds: const ['p1'],
          initialType: EntryType.irrigation,
          allowedTypes: potCompatibleEntryTypes,
          resolvePlantIds: () async => [...inPot],
        ),
      );
      // A plant moved into the pot while the form is open gets the entry.
      inPot.add('p2');
      await save(tester);
      // One moved in afterwards doesn't.
      inPot.add('p3');

      final entries = mutations.created.single;
      expect(entries.map((e) => e.plantId), ['p1', 'p2']);
      expect(entries.map((e) => e.type).toSet(), {EntryType.irrigation});
    });
  });

  group('reminder interval', () {
    ReminderStatus existing(EntryType type, int days, {bool enabled = true}) =>
        ReminderStatus(
          reminder: ReminderModel(
            id: 'r-${type.name}',
            plantId: 'p1',
            entryType: type,
            intervalDays: days,
            enabled: enabled,
            createdAt: DateTime(2026, 1, 1),
          ),
        );

    final reminderField = field('Repetir a cada (opcional)');

    testWidgets('is offered for reminder types only', (tester) async {
      await pump(tester, AddEntryScreen(plantId: 'p1'));
      // Observation is the default type, and has reminders.
      expect(reminderField, findsOneWidget);
      for (final (type, label) in [
        (EntryType.fertilizer, 'Fertilização'),
        (EntryType.pruning, 'Poda'),
        (EntryType.repotting, 'Replantio'),
      ]) {
        await selectType(tester, type, label);
        expect(reminderField, findsOneWidget, reason: label);
      }
      await selectType(tester, EntryType.irrigation, 'Irrigação');
      expect(reminderField, findsNothing);
    });

    testWidgets('saves the typed interval with the entry', (tester) async {
      await pump(tester,
          AddEntryScreen(plantId: 'p1', initialType: EntryType.pruning));
      await tester.enterText(reminderField, '45');
      await save(tester);

      expect(mutations.created.single.single.type, EntryType.pruning);
      expect(mutations.reminderIntervals.single, 45);
    });

    testWidgets('blank leaves the reminder alone', (tester) async {
      await pump(tester,
          AddEntryScreen(plantId: 'p1', initialType: EntryType.pruning));
      await save(tester);

      expect(mutations.reminderIntervals.single, isNull);
    });

    testWidgets('is prefilled with the enabled reminder of the type',
        (tester) async {
      await pump(tester,
          AddEntryScreen(plantId: 'p1', initialType: EntryType.fertilizer),
          reminders: [
            existing(EntryType.fertilizer, 30),
            existing(EntryType.pruning, 90, enabled: false),
          ]);
      expect(tester.widget<TextField>(reminderField).controller!.text, '30');

      // Switching type swaps the prefill; a paused reminder isn't offered,
      // so saving as is won't silently resume it.
      await selectType(tester, EntryType.pruning, 'Poda');
      expect(tester.widget<TextField>(reminderField).controller!.text, '');
    });

    testWidgets('an out-of-range interval blocks saving', (tester) async {
      await pump(tester,
          AddEntryScreen(plantId: 'p1', initialType: EntryType.fertilizer));
      await tester.enterText(reminderField, '400');
      await save(tester);

      expect(mutations.created, isEmpty);
      expect(find.text('Informe um número de dias entre 1 e 365'),
          findsOneWidget);
    });

    testWidgets('bulk applies to every plant without prefilling',
        (tester) async {
      await pump(
        tester,
        const AddEntryScreen.bulk(
          plantIds: ['p1', 'p2'],
          initialType: EntryType.fertilizer,
        ),
        reminders: [existing(EntryType.fertilizer, 30)],
      );
      expect(tester.widget<TextField>(reminderField).controller!.text, '');
      await tester.enterText(reminderField, '20');
      await tester.tap(find.text('Salvar para 2 plantas'));
      await tester.pumpAndSettle();

      expect(mutations.created.single, hasLength(2));
      expect(mutations.reminderIntervals.single, 20);
    });
  });

  group('harvest', () {
    PlantCarencia carencia(String plantId, String name, DateTime until,
            [List<String> products = const ['Óleo de Neem']]) =>
        (
          plantId: plantId,
          plantName: name,
          status: CarenciaStatus(until: until, productNames: products),
        );

    testWidgets('stores the quantity and the unit', (tester) async {
      await pump(tester, AddEntryScreen(plantId: 'p1'));
      await selectType(tester, EntryType.harvest, 'Colheita');

      await tester.enterText(field('Quantidade'), '1,5');
      await tester.tap(find.text('kg'));
      await tester.pump();
      await tester.enterText(find.byType(TextField).last, 'Bem madura');
      await save(tester);

      expect(carenciaChecker.checked, [
        ['p1']
      ]);
      final entry = mutations.created.single.single;
      expect(entry.type, EntryType.harvest);
      expect(entry.numericValue, isNull);
      expect(entry.note, 'Bem madura');
      expect(entry.extraData, '{"quantity":1.5,"unit":"kg"}');
      expect(entry.details,
          const HarvestDetails(quantity: 1.5, unit: HarvestUnit.kg));
      // No carência, no dialog.
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byType(AddEntryScreen), findsNothing);
    });

    testWidgets('without details stores no extraData', (tester) async {
      await pump(tester,
          AddEntryScreen(plantId: 'p1', initialType: EntryType.harvest));
      // A picked unit can be dropped again.
      final chip = find.widgetWithText(ChoiceChip, 'maços');
      await tester.tap(chip);
      await tester.pump();
      await tester.tap(chip);
      await tester.pump();
      await tester.enterText(field('Quantidade'), '0');
      await save(tester);

      expect(mutations.created.single.single.extraData, isNull);
    });

    testWidgets('other entry types skip the carência check', (tester) async {
      await pump(tester, AddEntryScreen(plantId: 'p1'),
          inCarencia: [carencia('p1', 'Tomateiro', DateTime(2026, 10, 12))]);
      await selectType(tester, EntryType.pruning, 'Poda');
      await save(tester);

      expect(carenciaChecker.checked, isEmpty);
      expect(find.byType(AlertDialog), findsNothing);
      expect(mutations.created, hasLength(1));
    });

    testWidgets('during carência asks first; cancelling saves nothing',
        (tester) async {
      await pump(
        tester,
        AddEntryScreen(plantId: 'p1', initialType: EntryType.harvest),
        inCarencia: [
          carencia('p1', 'Tomateiro', DateTime(2026, 10, 12),
              ['Óleo de Neem', 'Calda Bordalesa']),
        ],
      );
      await tester.enterText(field('Quantidade'), '300');
      await save(tester);

      expect(find.text('Colheita durante a carência'), findsOneWidget);
      expect(find.textContaining('em carência até 12/10'), findsOneWidget);
      expect(find.text('Produtos: Óleo de Neem, Calda Bordalesa'),
          findsOneWidget);
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(mutations.created, isEmpty);
      expect(find.byType(AlertDialog), findsNothing);
      // Still on the form, which can be saved again.
      expect(find.byType(AddEntryScreen), findsOneWidget);
      expect(
          tester
              .widget<FilledButton>(find.widgetWithText(
                  FilledButton, 'Salvar registro'))
              .onPressed,
          isNotNull);
    });

    testWidgets('during carência, confirming saves with the mark',
        (tester) async {
      await pump(
        tester,
        AddEntryScreen(plantId: 'p1', initialType: EntryType.harvest),
        inCarencia: [carencia('p1', 'Tomateiro', DateTime(2026, 10, 12))],
      );
      await tester.enterText(field('Quantidade'), '300');
      await tester.tap(find.text('g'));
      await tester.pump();
      await save(tester);
      await tester.tap(find.text('Registrar mesmo assim'));
      await tester.pumpAndSettle();

      final entry = mutations.created.single.single;
      expect(entry.extraData,
          '{"quantity":300.0,"unit":"g","duringCarencia":true}');
      expect(find.byType(AddEntryScreen), findsNothing);
    });

    testWidgets('bulk lists the plants in carência and marks only them',
        (tester) async {
      await pump(
        tester,
        const AddEntryScreen.bulk(
          plantIds: ['p1', 'p2', 'p3'],
          initialType: EntryType.harvest,
        ),
        inCarencia: [
          carencia('p1', 'Tomateiro', DateTime(2026, 10, 12)),
          carencia('p3', 'Alface', DateTime(2026, 10, 8), const []),
        ],
      );
      await tester.enterText(field('Quantidade'), '2');
      await tester.tap(find.text('unidades'));
      await tester.pump();
      await tester.tap(find.text('Salvar para 3 plantas'));
      await tester.pumpAndSettle();

      expect(carenciaChecker.checked, [
        ['p1', 'p2', 'p3']
      ]);
      expect(find.textContaining('2 plantas estão em carência'),
          findsOneWidget);
      expect(find.textContaining('• Tomateiro: até 12/10'), findsOneWidget);
      expect(find.textContaining('Produtos: Óleo de Neem'), findsOneWidget);
      expect(find.textContaining('• Alface: até 08/10'), findsOneWidget);
      await tester.tap(find.text('Registrar mesmo assim'));
      await tester.pumpAndSettle();

      final entries = mutations.created.single;
      expect(entries.map((e) => e.plantId), ['p1', 'p2', 'p3']);
      expect(
        entries.map((e) => (e.details as HarvestDetails).duringCarencia),
        [true, false, true],
      );
      expect(entries[1].extraData, '{"quantity":2.0,"unit":"units"}');
    });

    for (final (name, theme) in appThemes) {
      testWidgets('the form and the warning are readable in the $name theme',
          (tester) async {
        final semantics = tester.ensureSemantics();
        await pump(
          tester,
          AddEntryScreen(plantId: 'p1', initialType: EntryType.harvest),
          theme: theme,
          inCarencia: [carencia('p1', 'Tomateiro', DateTime(2026, 10, 12))],
        );
        await tester.tap(find.text('kg'));
        await paintBackground(tester);
        await expectReadableText(tester);
        expect(find.bySemanticsLabel(emojiLabel), findsNothing);

        await save(tester);
        expect(find.byType(AlertDialog), findsOneWidget);
        await expectReadableText(tester);
        await expectTapTargetGuidelines(tester);
        semantics.dispose();
      });
    }
  });

  group('accessibility', () {
    const manualTypes = [
      EntryType.observation,
      EntryType.irrigation,
      EntryType.fertilizer,
      EntryType.pruning,
      EntryType.height,
      EntryType.chlorosis,
      EntryType.pest,
      EntryType.pesticide,
      EntryType.repotting,
      EntryType.harvest,
    ];

    testWidgets('meets the tap target and labelling guidelines',
        (tester) async {
      final semantics = tester.ensureSemantics();
      for (final type in manualTypes) {
        await pump(tester, AddEntryScreen(plantId: 'p1', initialType: type));
        await expectTapTargetGuidelines(tester);
      }
      semantics.dispose();
    });

    testWidgets('type chips and section titles are read without the emoji',
        (tester) async {
      final semantics = tester.ensureSemantics();
      await pump(tester,
          AddEntryScreen(plantId: 'p1', initialType: EntryType.irrigation));

      expect(find.bySemanticsLabel(emojiLabel), findsNothing);
      expect(
        tester.getSemantics(find.widgetWithText(
            ChoiceChip, '${EntryType.irrigation.emoji} Irrigação')),
        matchesSemantics(
          label: 'Irrigação',
          isButton: true,
          isSelected: true,
          hasSelectedState: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      semantics.dispose();
    });

    for (final (name, theme) in appThemes) {
      testWidgets('text is readable in the $name theme', (tester) async {
        final semantics = tester.ensureSemantics();
        for (final type in manualTypes) {
          await pump(tester, AddEntryScreen(plantId: 'p1', initialType: type),
              theme: theme);
          await paintBackground(tester);
          await expectReadableText(tester);
        }
        semantics.dispose();
      });
    }

    for (final (name, theme) in appThemes) {
      testWidgets('a picked pot material is readable in the $name theme',
          (tester) async {
        final semantics = tester.ensureSemantics();
        await pump(tester,
            AddEntryScreen(plantId: 'p1', initialType: EntryType.repotting),
            theme: theme);
        await tester.tap(find.text('Cerâmica'));
        await paintBackground(tester);
        await expectReadableText(tester);
        expect(find.bySemanticsLabel(emojiLabel), findsNothing);
        semantics.dispose();
      });
    }

    testWidgets('health score buttons say what they mean', (tester) async {
      final semantics = tester.ensureSemantics();
      await pump(tester, AddEntryScreen(plantId: 'p1'));

      expect(find.bySemanticsLabel('Saúde 4/5 — Boa'), findsOneWidget);
      semantics.dispose();
    });

    for (final scale in [1.5, 2.0]) {
      testWidgets('lays out without overflow at text scale $scale',
          (tester) async {
        setTextScale(tester, scale);
        for (final type in manualTypes) {
          await pump(
            tester,
            AddEntryScreen(plantId: 'p1', initialType: type),
            size: const Size(400, 3000),
          );
          expect(tester.takeException(), isNull, reason: '$type');
        }
      });
    }
  });
}
