import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:polypodium/core/enums.dart';
import 'package:polypodium/core/sync/sync_providers.dart';
import 'package:polypodium/core/widgets/emoji_text.dart';
import 'package:polypodium/features/settings/presentation/providers/settings_providers.dart';
import 'package:polypodium/features/soils/domain/soil_model.dart';
import 'package:polypodium/features/soils/presentation/providers/soils_providers.dart';
import 'package:polypodium/features/species/data/external_species_repository.dart';
import 'package:polypodium/features/species/domain/species_model.dart';
import 'package:polypodium/features/species/presentation/providers/species_providers.dart';
import 'package:polypodium/features/species/presentation/screens/add_species_screen.dart';
import 'package:polypodium/features/species/presentation/screens/species_list_screen.dart';
import 'package:polypodium/features/species/presentation/widgets/species_autocomplete.dart';
import 'package:polypodium/l10n/app_localizations.dart';

import '../../../helpers/accessibility.dart';

class _FakeTransparencyNotifier extends TransparencyEnabledNotifier {
  @override
  bool build() => true;
}

class _FakeSpeciesNotifier extends SpeciesNotifier {
  _FakeSpeciesNotifier(this.species, this.saved, this.deleted);
  final List<SpeciesModel> species;
  final List<SpeciesModel> saved;
  final List<String> deleted;

  @override
  Stream<List<SpeciesModel>> build() => Stream.value(species);

  @override
  Future<void> save(SpeciesModel species) async => saved.add(species);

  @override
  Future<void> delete(String id) async => deleted.add(id);
}

class _FakeSoilsNotifier extends SoilsNotifier {
  @override
  Stream<List<SoilModel>> build() => Stream.value([
        SoilModel(id: 'loamy', name: 'Franco', createdAt: DateTime(2024, 1, 1)),
        SoilModel(
            id: 'sandy', name: 'Arenoso', createdAt: DateTime(2024, 1, 1)),
      ]);
}

class _FakeExternalSpeciesRepository extends ExternalSpeciesRepository {
  @override
  Future<void> build() async {}

  @override
  Future<int> getSpeciesCount() async => 1234;

  @override
  Future<String> getLastUpdateDate() async => '2026-05-01';

  @override
  Future<List<ExternalSpecies>> search(String query) async => [
        if ('costela-de-adão'.contains(query.toLowerCase()))
          ExternalSpecies(
            popularName: 'Costela-de-adão',
            scientificName: 'Monstera deliciosa',
          ),
      ];
}

void main() {
  final species = [
    SpeciesModel(
      id: 's1',
      popularName: 'Samambaia',
      scientificName: 'Polypodium vulgare',
      defaultIrrigationFrequencyDays: 3,
      recommendedSoilIds: const ['loamy'],
      light: LightRequirement.partialShade,
      humidity: HumidityLevel.high,
      petToxicity: PetToxicity.toxic,
      floweringMonths: const {9, 10},
      careNotes: 'Borrifar as folhas',
      createdAt: DateTime(2024, 1, 1),
    ),
    SpeciesModel(
      id: 's2',
      popularName: 'Jiboia',
      scientificName: 'Epipremnum aureum',
      defaultIrrigationFrequencyDays: null,
      recommendedSoilIds: const [],
      createdAt: DateTime(2024, 1, 2),
    ),
  ];

  late List<SpeciesModel> saved;
  late List<String> deleted;

  Future<void> pump(WidgetTester tester, List<SpeciesModel> species,
      {ThemeData? theme}) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    saved = [];
    deleted = [];
    await tester.pumpWidget(ProviderScope(
      overrides: [
        transparencyEnabledNotifierProvider
            .overrideWith(_FakeTransparencyNotifier.new),
        speciesNotifierProvider
            .overrideWith(() => _FakeSpeciesNotifier(species, saved, deleted)),
        soilsNotifierProvider.overrideWith(_FakeSoilsNotifier.new),
        externalSpeciesRepositoryProvider
            .overrideWith(_FakeExternalSpeciesRepository.new),
        pushCursorToServerProvider.overrideWith((ref) async => null),
      ],
      child: MaterialApp(
        theme: theme,
        locale: const Locale('pt'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const SpeciesListScreen(),
      ),
    ));
    await tester.pumpAndSettle();
  }

  Future<void> search(WidgetTester tester, String query) async {
    await tester.enterText(find.byType(TextField).first, query);
    // Past the search debounce.
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
  }

  Finder field(String label) => find.widgetWithText(TextFormField, label);

  /// A care chip, whose visible text is prefixed by an emoji.
  Finder careChip(String label) =>
      find.byWidgetPredicate((w) => w is EmojiText && w.text == label);

  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pump();
  }

  testWidgets('lists the species and searches them', (tester) async {
    await pump(tester, species);

    expect(find.text('Total de espécies disponíveis: 1234'), findsOneWidget);
    expect(find.text('Última atualização: 2026-05-01'), findsOneWidget);
    expect(find.text('Samambaia'), findsOneWidget);
    expect(find.text('Polypodium vulgare'), findsOneWidget);
    expect(find.text('Jiboia'), findsOneWidget);
    expect(tester.getTopLeft(find.text('Jiboia')).dy,
        lessThan(tester.getTopLeft(find.text('Samambaia')).dy));

    // Matches the scientific name too.
    await search(tester, 'epiprem');
    expect(find.text('Jiboia'), findsOneWidget);
    expect(find.text('Samambaia'), findsNothing);

    await search(tester, 'cacto');
    expect(find.text('Nenhuma espécie encontrada'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.tune));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nome Popular (Z-A)'));
    await tester.pumpAndSettle();
    await search(tester, '');
    expect(tester.getTopLeft(find.text('Samambaia')).dy,
        lessThan(tester.getTopLeft(find.text('Jiboia')).dy));
  });

  testWidgets('shows the empty state without species', (tester) async {
    await pump(tester, []);
    expect(find.text('Nenhuma espécie cadastrada'), findsOneWidget);
  });

  testWidgets('creates a species picked from the external dataset',
      (tester) async {
    await pump(tester, species);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.text('Nova espécie'), findsOneWidget);

    await tester.tap(find.text('Adicionar espécie'));
    await tester.pumpAndSettle();
    expect(find.text('Campo obrigatório'), findsNWidgets(2));
    expect(saved, isEmpty);

    await tester.enterText(
        find.descendant(
            of: find.byType(SpeciesAutocomplete),
            matching: find.byType(TextFormField)),
        'costela');
    // Past the autocomplete's debounce.
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Monstera deliciosa'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextFormField>(field('Nome científico *')).controller!.text,
      'Monstera deliciosa',
    );

    await tester.enterText(field('Frequência de irrigação padrão (dias)'), '5');
    await tester.tap(find.text('Franco'));
    await tester.pump();
    await tester.tap(find.text('Adicionar espécie'));
    await tester.pumpAndSettle();

    final created = saved.single;
    expect(created.popularName, 'Costela-de-adão');
    expect(created.scientificName, 'Monstera deliciosa');
    expect(created.defaultIrrigationFrequencyDays, 5);
    expect(created.recommendedSoilIds, ['loamy']);
    expect(find.byType(AddSpeciesScreen), findsNothing);
  });

  testWidgets('edits a species from its edit button', (tester) async {
    await pump(tester, species);

    // Samambaia is listed second.
    await tester.tap(find.byIcon(Icons.edit_outlined).last);
    await tester.pumpAndSettle();
    expect(find.text('Editar espécie'), findsOneWidget);

    await tester.tap(find.text('Franco'));
    await tester.pump();
    await tester.tap(find.text('Arenoso'));
    await tester.pump();
    await tester.tap(find.text('Salvar alterações'));
    await tester.pumpAndSettle();

    final edited = saved.single;
    expect(edited.id, 's1');
    expect(edited.popularName, 'Samambaia');
    expect(edited.scientificName, 'Polypodium vulgare');
    expect(edited.defaultIrrigationFrequencyDays, 3);
    expect(edited.recommendedSoilIds, ['sandy']);
    expect(edited.createdAt, DateTime(2024, 1, 1));
    // The care sheet is kept untouched.
    expect(edited.light, LightRequirement.partialShade);
    expect(edited.humidity, HumidityLevel.high);
    expect(edited.petToxicity, PetToxicity.toxic);
    expect(edited.floweringMonths, {9, 10});
    expect(edited.careNotes, 'Borrifar as folhas');
  });

  testWidgets('shows the light and pet toxicity badges', (tester) async {
    await pump(tester, species);

    expect(find.text('Meia-sombra'), findsOneWidget);
    expect(find.text('Tóxica para pets'), findsOneWidget);
    // Jiboia has no care sheet: only Samambaia's badges show.
    expect(find.text('Sol pleno'), findsNothing);
  });

  testWidgets('fills in the care sheet of a new species', (tester) async {
    await pump(tester, species);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.text('Cuidados'), findsOneWidget);

    await tester.enterText(
        find.descendant(
            of: find.byType(SpeciesAutocomplete),
            matching: find.byType(TextFormField)),
        'Espada-de-são-jorge');
    await tester.enterText(field('Nome científico *'), 'Dracaena trifasciata');
    await tapVisible(tester, careChip('Sol pleno'));
    await tapVisible(tester, careChip('Baixa'));
    await tapVisible(tester, careChip('Tóxica'));
    await tapVisible(tester, find.text('mar.'));
    await tapVisible(tester, find.text('abr.'));
    await tapVisible(tester, find.text('nov.'));
    // Toggling a month again removes it.
    await tapVisible(tester, find.text('nov.'));
    await tester.enterText(
        field('Observações de cuidado'), '  Pouca água no inverno ');

    await tapVisible(tester, find.text('Adicionar espécie'));
    await tester.pumpAndSettle();

    final created = saved.single;
    expect(created.popularName, 'Espada-de-são-jorge');
    expect(created.light, LightRequirement.fullSun);
    expect(created.humidity, HumidityLevel.low);
    expect(created.petToxicity, PetToxicity.toxic);
    expect(created.floweringMonths, {3, 4});
    expect(created.careNotes, 'Pouca água no inverno');
  });

  testWidgets('clears the care sheet when editing', (tester) async {
    await pump(tester, species);

    await tester.tap(find.byIcon(Icons.edit_outlined).last);
    await tester.pumpAndSettle();

    // Tapping the selected light and humidity deselects them.
    await tapVisible(tester, careChip('Meia-sombra'));
    await tapVisible(tester, careChip('Alta'));
    await tapVisible(tester, careChip('Não informada'));
    await tapVisible(tester, find.text('set.'));
    await tapVisible(tester, find.text('out.'));
    await tester.enterText(field('Observações de cuidado'), ' ');
    await tapVisible(tester, find.text('Salvar alterações'));
    await tester.pumpAndSettle();

    final edited = saved.single;
    expect(edited.light, isNull);
    expect(edited.humidity, isNull);
    expect(edited.petToxicity, PetToxicity.unknown);
    expect(edited.floweringMonths, isEmpty);
    expect(edited.careNotes, isNull);
    expect(edited.hasCareInfo, isFalse);
  });

  group('accessibility', () {
    testWidgets('the care chips meet the tap target and labelling guidelines',
        (tester) async {
      final semantics = tester.ensureSemantics();
      await pump(tester, species);
      await tester.tap(find.byIcon(Icons.edit_outlined).last);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Observações de cuidado'));
      await tester.pumpAndSettle();

      await expectTapTargetGuidelines(tester);
      // Emojis are not read out; months are read by their full name.
      expect(find.bySemanticsLabel(emojiLabel), findsNothing);
      expect(find.bySemanticsLabel('setembro'), findsOneWidget);
      expect(
        tester.getSemantics(careChip('Meia-sombra')),
        matchesSemantics(
          label: 'Meia-sombra',
          isSelected: true,
          hasSelectedState: true,
          hasEnabledState: true,
          isEnabled: true,
          isButton: true,
          hasTapAction: true,
          hasFocusAction: true,
          isFocusable: true,
        ),
      );
      semantics.dispose();
    });

    testWidgets('the list badges do not read emoji names out',
        (tester) async {
      final semantics = tester.ensureSemantics();
      await pump(tester, species);
      expect(find.bySemanticsLabel(emojiLabel), findsNothing);
      semantics.dispose();
    });

    for (final (name, theme) in appThemes) {
      testWidgets('the list badges are readable in the $name theme',
          (tester) async {
        final semantics = tester.ensureSemantics();
        await pump(tester, species, theme: theme);
        await paintBackground(tester);
        await expectReadableText(tester);
        semantics.dispose();
      });
    }
  });

  testWidgets('deletes a species after confirming', (tester) async {
    await pump(tester, species);

    await tester.tap(find.byIcon(Icons.delete_outline).first);
    await tester.pumpAndSettle();
    expect(find.text('Deletar espécie?'), findsOneWidget);
    await tester.tap(find.text('Deletar'));
    await tester.pumpAndSettle();
    expect(deleted, ['s2']);
  });
}
