import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:polypodium/core/enums.dart';
import 'package:polypodium/core/storage/photo_storage.dart';
import 'package:polypodium/core/storage/photo_storage_provider.dart';
import 'package:polypodium/features/defensivos/domain/defensivo_model.dart';
import 'package:polypodium/features/defensivos/presentation/providers/defensivos_search_providers.dart';
import 'package:polypodium/features/defensivos/presentation/widgets/defensivo_selection_field.dart';
import 'package:polypodium/features/entries/domain/entry_model.dart';
import 'package:polypodium/features/entries/presentation/providers/entries_providers.dart';
import 'package:polypodium/features/entries/presentation/screens/add_entry_screen.dart';
import 'package:polypodium/l10n/app_localizations.dart';

class _FakeEntryMutations implements EntryMutations {
  final created = <List<EntryModel>>[];

  @override
  Future<void> createMany(List<EntryModel> entries) async =>
      created.add(entries);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  final defensivos = [
    DefensivoModel(
        id: 'd1', name: 'Óleo de Neem', createdAt: DateTime(2026, 1, 1)),
    DefensivoModel(
        id: 'd2', name: 'Calda Bordalesa', createdAt: DateTime(2026, 1, 1)),
  ];

  late _FakeEntryMutations mutations;

  // Pushes [screen] over a launcher route so the Navigator.pop on save has
  // somewhere to go back to.
  Future<void> pump(WidgetTester tester, AddEntryScreen screen) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    // Start from scratch when a test opens the screen more than once.
    await tester.pumpWidget(const SizedBox());
    mutations = _FakeEntryMutations();
    await tester.pumpWidget(ProviderScope(
      overrides: [
        entryMutationsProvider.overrideWithValue(mutations),
        photoStorageProvider
            .overrideWithValue(PhotoStorage(baseDirName: 'test_photos')),
        filteredSortedDefensivosProvider
            .overrideWith((ref) async => defensivos),
      ],
      child: MaterialApp(
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
      '{"defensivoId":"d2","name":"Calda Bordalesa"}],"recurrenceDays":15}',
    );
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
}
