import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:polypodium/features/settings/presentation/providers/settings_providers.dart';
import 'package:polypodium/features/soils/domain/soil_model.dart';
import 'package:polypodium/features/soils/presentation/providers/soils_providers.dart';
import 'package:polypodium/features/soils/presentation/screens/add_edit_soil_screen.dart';
import 'package:polypodium/features/soils/presentation/screens/soils_list_screen.dart';
import 'package:polypodium/l10n/app_localizations.dart';

class _FakeTransparencyNotifier extends TransparencyEnabledNotifier {
  @override
  bool build() => true;
}

class _FakeSoilsNotifier extends SoilsNotifier {
  _FakeSoilsNotifier(this.soils, this.saved, this.deleted);
  final List<SoilModel> soils;
  final List<SoilModel> saved;
  final List<String> deleted;

  @override
  Stream<List<SoilModel>> build() => Stream.value(soils);

  @override
  Future<void> save(SoilModel soil) async => saved.add(soil);

  @override
  Future<void> delete(String soilId) async => deleted.add(soilId);
}

void main() {
  final soils = [
    SoilModel(
      id: 'loamy',
      name: 'Franco',
      composition: 'Areia e argila',
      createdAt: DateTime(2024, 1, 1),
    ),
    SoilModel(id: 'sandy', name: 'Arenoso', createdAt: DateTime(2024, 1, 2)),
    SoilModel(id: 'clay', name: 'Argiloso', createdAt: DateTime(2024, 1, 3)),
  ];

  late List<SoilModel> saved;
  late List<String> deleted;

  Future<void> pump(WidgetTester tester, List<SoilModel> soils) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    saved = [];
    deleted = [];
    await tester.pumpWidget(ProviderScope(
      overrides: [
        transparencyEnabledNotifierProvider
            .overrideWith(_FakeTransparencyNotifier.new),
        soilsNotifierProvider
            .overrideWith(() => _FakeSoilsNotifier(soils, saved, deleted)),
      ],
      child: const MaterialApp(
        locale: Locale('pt'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SoilsListScreen(),
      ),
    ));
    await tester.pumpAndSettle();
  }

  Future<void> search(WidgetTester tester, String query) async {
    await tester.enterText(find.byType(TextField), query);
    // Past the search debounce.
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
  }

  Finder field(String label) => find.widgetWithText(TextFormField, label);

  testWidgets('lists the soils by name and searches them', (tester) async {
    await pump(tester, soils);

    expect(find.text('Arenoso'), findsOneWidget);
    expect(find.text('Argiloso'), findsOneWidget);
    expect(find.text('Franco'), findsOneWidget);
    expect(find.text('Areia e argila'), findsOneWidget);
    expect(tester.getTopLeft(find.text('Arenoso')).dy,
        lessThan(tester.getTopLeft(find.text('Franco')).dy));

    // Matches the composition too.
    await search(tester, 'argila');
    expect(find.text('Franco'), findsOneWidget);
    expect(find.text('Arenoso'), findsNothing);
    expect(find.text('Argiloso'), findsNothing);

    await search(tester, 'turfa');
    expect(find.text('Nenhum solo encontrado'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.tune));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nome (Z-A)'));
    await tester.pumpAndSettle();
    await search(tester, '');
    expect(tester.getTopLeft(find.text('Franco')).dy,
        lessThan(tester.getTopLeft(find.text('Arenoso')).dy));
  });

  testWidgets('shows the empty state without soils', (tester) async {
    await pump(tester, []);
    expect(find.text('Nenhum tipo de solo cadastrado'), findsOneWidget);
  });

  testWidgets('creates a soil from the FAB', (tester) async {
    await pump(tester, soils);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.text('Novo Solo'), findsOneWidget);

    await tester.tap(find.text('Criar solo'));
    await tester.pumpAndSettle();
    expect(find.text('Informe um nome'), findsOneWidget);
    expect(saved, isEmpty);

    await tester.enterText(field('Nome do Solo *'), ' Turfa ');
    await tester.enterText(field('Composição (opcional)'), 'Musgo decomposto');
    await tester.tap(find.text('Criar solo'));
    await tester.pumpAndSettle();

    final soil = saved.single;
    expect(soil.name, 'Turfa');
    expect(soil.composition, 'Musgo decomposto');
    expect(soil.imagePath, isNull);
    expect(soil.imageSource, isNull);
    expect(find.byType(AddEditSoilScreen), findsNothing);
  });

  testWidgets('edits a soil from its row', (tester) async {
    await pump(tester, soils);

    await tester.tap(find.text('Franco'));
    await tester.pumpAndSettle();
    expect(find.text('Editar solo'), findsOneWidget);

    await tester.enterText(field('Nome do Solo *'), 'Franco-arenoso');
    await tester.tap(find.text('Salvar alterações'));
    await tester.pumpAndSettle();

    final soil = saved.single;
    expect(soil.id, 'loamy');
    expect(soil.name, 'Franco-arenoso');
    expect(soil.composition, 'Areia e argila');
    expect(soil.createdAt, DateTime(2024, 1, 1));
  });

  testWidgets('deletes a soil after confirming', (tester) async {
    await pump(tester, soils);

    await tester.tap(find.byIcon(Icons.delete_outline).first);
    await tester.pumpAndSettle();
    expect(find.text('Deletar solo?'), findsOneWidget);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(deleted, isEmpty);

    await tester.tap(find.byIcon(Icons.delete_outline).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Deletar'));
    await tester.pumpAndSettle();
    expect(deleted, ['sandy']);
  });
}
