import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:polypodium/core/enums.dart';
import 'package:polypodium/core/storage/photo_storage.dart';
import 'package:polypodium/core/storage/photo_storage_provider.dart';
import 'package:polypodium/features/defensivos/domain/defensivo_model.dart';
import 'package:polypodium/features/defensivos/presentation/providers/defensivos_providers.dart';
import 'package:polypodium/features/defensivos/presentation/screens/add_edit_defensivo_screen.dart';
import 'package:polypodium/features/defensivos/presentation/screens/defensivos_list_screen.dart';
import 'package:polypodium/features/settings/presentation/providers/settings_providers.dart';
import 'package:polypodium/l10n/app_localizations.dart';

class _FakeTransparencyNotifier extends TransparencyEnabledNotifier {
  @override
  bool build() => true;
}

class _FakeDefensivosNotifier extends DefensivosNotifier {
  _FakeDefensivosNotifier(this.defensivos, this.saved, this.deleted);
  final List<DefensivoModel> defensivos;
  final List<DefensivoModel> saved;
  final List<String> deleted;

  @override
  Stream<List<DefensivoModel>> build() => Stream.value(defensivos);

  @override
  Future<void> save(DefensivoModel defensivo) async => saved.add(defensivo);

  @override
  Future<void> delete(String defensivoId) async => deleted.add(defensivoId);
}

void main() {
  final defensivos = [
    DefensivoModel(
      id: 'd1',
      name: 'Óleo de Neem',
      category: DefensivoCategory.insecticide,
      createdAt: DateTime(2026, 1, 1),
    ),
    DefensivoModel(
      id: 'd2',
      name: 'Calda Bordalesa',
      category: DefensivoCategory.fungicide,
      composition: 'Sulfato de cobre e cal',
      carenciaDays: 7,
      createdAt: DateTime(2026, 1, 2),
    ),
  ];

  late List<DefensivoModel> saved;
  late List<String> deleted;

  Future<void> pump(
      WidgetTester tester, List<DefensivoModel> defensivos) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    saved = [];
    deleted = [];
    await tester.pumpWidget(ProviderScope(
      overrides: [
        transparencyEnabledNotifierProvider
            .overrideWith(_FakeTransparencyNotifier.new),
        defensivosNotifierProvider.overrideWith(
            () => _FakeDefensivosNotifier(defensivos, saved, deleted)),
        photoStorageProvider
            .overrideWithValue(PhotoStorage(baseDirName: 'test_photos')),
      ],
      child: const MaterialApp(
        locale: Locale('pt'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: DefensivosListScreen(),
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

  testWidgets('lists the defensivos by name and searches them', (tester) async {
    await pump(tester, defensivos);

    expect(find.text('Óleo de Neem'), findsOneWidget);
    expect(find.text('Inseticida'), findsOneWidget);
    expect(find.text('Calda Bordalesa'), findsOneWidget);
    expect(find.text('Fungicida'), findsOneWidget);
    expect(tester.getTopLeft(find.text('Calda Bordalesa')).dy,
        lessThan(tester.getTopLeft(find.text('Óleo de Neem')).dy));

    // Accent-insensitive.
    await search(tester, 'oleo');
    expect(find.text('Óleo de Neem'), findsOneWidget);
    expect(find.text('Calda Bordalesa'), findsNothing);

    await search(tester, 'enxofre');
    expect(find.text('Nenhum defensivo encontrado'), findsOneWidget);
  });

  testWidgets('shows the empty state without defensivos', (tester) async {
    await pump(tester, []);
    expect(find.text('Nenhum defensivo cadastrado'), findsOneWidget);
  });

  testWidgets('creates a defensivo from the FAB', (tester) async {
    await pump(tester, defensivos);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.text('Novo Defensivo'), findsOneWidget);

    await tester.tap(find.text('Criar defensivo'));
    await tester.pumpAndSettle();
    expect(find.text('Informe um nome'), findsOneWidget);
    expect(saved, isEmpty);

    await tester.enterText(field('Nome do Defensivo *'), ' Sabão potássico ');
    await tester.tap(find.text('Inseticida'));
    await tester.pump();
    await tester.enterText(field('Carência / reentrada (opcional)'), '3');
    await tester.tap(find.text('Criar defensivo'));
    await tester.pumpAndSettle();

    final defensivo = saved.single;
    expect(defensivo.name, 'Sabão potássico');
    expect(defensivo.category, DefensivoCategory.insecticide);
    expect(defensivo.customCategoryLabel, isNull);
    expect(defensivo.composition, isNull);
    expect(defensivo.carenciaDays, 3);
    expect(defensivo.imagePath, isNull);
    expect(find.byType(AddEditDefensivoScreen), findsNothing);
  });

  testWidgets('edits a defensivo from its row', (tester) async {
    await pump(tester, defensivos);

    await tester.tap(find.text('Calda Bordalesa'));
    await tester.pumpAndSettle();
    expect(find.text('Editar defensivo'), findsOneWidget);

    // Tapping the selected category clears it.
    await tester.tap(find.text('Fungicida'));
    await tester.pump();
    await tester.tap(find.text('Salvar alterações'));
    await tester.pumpAndSettle();

    final defensivo = saved.single;
    expect(defensivo.id, 'd2');
    expect(defensivo.name, 'Calda Bordalesa');
    expect(defensivo.category, isNull);
    expect(defensivo.composition, 'Sulfato de cobre e cal');
    expect(defensivo.carenciaDays, 7);
    expect(defensivo.createdAt, DateTime(2026, 1, 2));
  });

  testWidgets('deletes a defensivo after confirming', (tester) async {
    await pump(tester, defensivos);

    await tester.tap(find.byIcon(Icons.delete_outline).last);
    await tester.pumpAndSettle();
    expect(find.text('Deletar defensivo?'), findsOneWidget);
    await tester.tap(find.text('Deletar'));
    await tester.pumpAndSettle();
    expect(deleted, ['d1']);
  });
}
