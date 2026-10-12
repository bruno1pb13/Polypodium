import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:polypodium/core/enums.dart';
import 'package:polypodium/core/storage/photo_storage.dart';
import 'package:polypodium/core/storage/photo_storage_provider.dart';
import 'package:polypodium/features/entries/domain/entry_model.dart';
import 'package:polypodium/features/entries/presentation/providers/entries_providers.dart';
import 'package:polypodium/features/entries/presentation/screens/edit_entry_screen.dart';
import 'package:polypodium/l10n/app_localizations.dart';

class _FakeEntryMutations implements EntryMutations {
  final edits = <(String, String?, List<String>)>[];

  @override
  Future<void> edit(String entryId,
      {required String? note,
      required List<String> photoPaths,
      Iterable<String> newPhotoPaths = const []}) async {
    edits.add((entryId, note, List.of(photoPaths)));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _FakeEntryMutations mutations;

  final entry = EntryModel(
    id: 'e1',
    plantId: 'p1',
    date: DateTime(2026, 3, 4, 10, 30),
    type: EntryType.observation,
    note: 'folhas novas',
    photoPath: '/a.jpg',
    extraPhotos: const [EntryPhoto(id: 'e1-ph2', path: '/b.jpg')],
    createdAt: DateTime(2026, 3, 4),
  );

  Future<void> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    mutations = _FakeEntryMutations();
    await tester.pumpWidget(ProviderScope(
      overrides: [
        entryMutationsProvider.overrideWithValue(mutations),
        photoStorageProvider
            .overrideWithValue(PhotoStorage(baseDirName: 'test_photos')),
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
                MaterialPageRoute(
                    builder: (_) => EditEntryScreen(entry: entry)),
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

  testWidgets('opens with the entry note and photos', (tester) async {
    await pump(tester);

    expect(find.text('Editar registro'), findsOneWidget);
    expect(find.text('folhas novas'), findsOneWidget);
    expect(find.text('2 de 5'), findsOneWidget);
  });

  testWidgets('saves the edited note and the photos left', (tester) async {
    await pump(tester);

    await tester.enterText(find.byType(TextField), '  brotou  ');
    await tester.tap(find.byTooltip('Remover foto 1'));
    await tester.pump();
    await tester.tap(find.text('Salvar alterações'));
    await tester.pumpAndSettle();

    final (id, note, photos) = mutations.edits.single;
    expect((id, note), ('e1', 'brotou'));
    expect(photos, ['/b.jpg']);
    expect(find.byType(EditEntryScreen), findsNothing);
  });

  testWidgets('a cleared note is saved as none', (tester) async {
    await pump(tester);

    await tester.enterText(find.byType(TextField), '   ');
    await tester.tap(find.text('Salvar alterações'));
    await tester.pumpAndSettle();

    expect(mutations.edits.single.$2, isNull);
  });
}
