import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:polypodium/core/storage/photo_picker.dart';
import 'package:polypodium/core/storage/photo_storage.dart';
import 'package:polypodium/core/storage/photo_storage_provider.dart';
import 'package:polypodium/features/entries/domain/entry_model.dart';
import 'package:polypodium/features/entries/presentation/providers/entries_providers.dart';
import 'package:polypodium/features/entries/presentation/screens/add_entry_screen.dart';
import 'package:polypodium/l10n/app_localizations.dart';

import '../../../helpers/accessibility.dart';

class _FakeEntryMutations implements EntryMutations {
  final created = <List<EntryModel>>[];

  @override
  Future<void> createMany(List<EntryModel> entries) async =>
      created.add(entries);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Hands out the next batch of picked files, recording each request.
class _FakePhotoPicker implements PhotoPicker {
  final batches = <List<String>>[];
  final requests = <(ImageSource, int)>[];

  @override
  Future<List<String>> pick(ImageSource source, {int limit = 1}) async {
    requests.add((source, limit));
    return batches.isEmpty ? const [] : batches.removeAt(0);
  }
}

/// Names saved copies in order without touching the disk.
class _FakePhotoStorage implements PhotoStorage {
  var _saved = 0;
  final deleted = <String>[];

  @override
  String get baseDirName => 'test_photos';

  @override
  Future<String> savePhoto(File sourceFile) async => '/saved/${++_saved}.jpg';

  @override
  Future<void> deletePhoto(String path) async => deleted.add(path);

  @override
  Future<void> cleanOrphanPhotos(List<String> referencedPaths) async {}

  @override
  Future<String> savePhotoBytes(List<int> bytes, String fileName) async => '';

  @override
  Future<String> restorePhoto(List<int> bytes, String fileName) async => '';
}

void main() {
  late _FakeEntryMutations mutations;
  late _FakePhotoPicker picker;
  late _FakePhotoStorage storage;

  Future<void> pump(WidgetTester tester, AddEntryScreen screen,
      {ThemeData? theme}) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    mutations = _FakeEntryMutations();
    picker = _FakePhotoPicker();
    storage = _FakePhotoStorage();
    await tester.pumpWidget(ProviderScope(
      overrides: [
        entryMutationsProvider.overrideWithValue(mutations),
        photoPickerProvider.overrideWithValue(picker),
        photoStorageProvider.overrideWithValue(storage),
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

  Future<void> tapButton(WidgetTester tester, String label) async {
    await tester.ensureVisible(find.text(label));
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }

  testWidgets('picks several photos up to the limit and saves them in order',
      (tester) async {
    await pump(tester, AddEntryScreen(plantId: 'p1'));
    picker.batches.addAll([
      ['/pick/a.jpg', '/pick/b.jpg', '/pick/c.jpg'],
      ['/pick/d.jpg'],
      ['/pick/e.jpg'],
    ]);

    await tapButton(tester, 'Galeria');
    expect(picker.requests.single, (ImageSource.gallery, 5));
    expect(find.text('3 de 5'), findsOneWidget);
    expect(find.bySemanticsLabel('Foto 1 de 3'), findsOneWidget);

    await tapButton(tester, 'Câmera');
    expect(picker.requests.last, (ImageSource.camera, 2));
    await tapButton(tester, 'Galeria');
    expect(picker.requests.last, (ImageSource.gallery, 1));
    // Full: no more buttons.
    expect(find.text('5 de 5'), findsOneWidget);
    expect(find.text('Galeria'), findsNothing);
    expect(find.text('Câmera'), findsNothing);

    await tester.tap(find.byTooltip('Remover foto 2'));
    await tester.pumpAndSettle();
    expect(storage.deleted, ['/saved/2.jpg']);
    expect(find.text('4 de 5'), findsOneWidget);
    expect(find.text('Galeria'), findsOneWidget);

    await tapButton(tester, 'Salvar registro');

    final entry = mutations.created.single.single;
    expect(entry.photoPath, '/saved/1.jpg');
    expect(entry.extraPhotos.map((p) => p.path),
        ['/saved/3.jpg', '/saved/4.jpg', '/saved/5.jpg']);
    expect(entry.photos.map((p) => p.id).toSet(), hasLength(4));
    expect(storage.deleted, ['/saved/2.jpg']);
  });

  testWidgets('a bulk entry gives each plant its own copies', (tester) async {
    await pump(tester, const AddEntryScreen.bulk(plantIds: ['p1', 'p2']));
    picker.batches.add(['/pick/a.jpg', '/pick/b.jpg']);
    await tapButton(tester, 'Galeria');

    await tapButton(tester, 'Salvar para 2 plantas');

    final [first, second] = mutations.created.single;
    expect(first.photos.map((p) => p.path), ['/saved/1.jpg', '/saved/2.jpg']);
    expect(second.photos.map((p) => p.path), ['/saved/3.jpg', '/saved/4.jpg']);
    expect(first.extraPhotos.single.id, isNot(second.extraPhotos.single.id));
  });

  testWidgets('leaving without saving deletes the picked copies',
      (tester) async {
    await pump(tester, AddEntryScreen(plantId: 'p1'));
    picker.batches.add(['/pick/a.jpg', '/pick/b.jpg']);
    await tapButton(tester, 'Galeria');

    tester.state<NavigatorState>(find.byType(Navigator)).pop();
    await tester.pumpAndSettle();

    expect(storage.deleted, ['/saved/1.jpg', '/saved/2.jpg']);
    expect(mutations.created, isEmpty);
  });

  testWidgets('the previews meet the tap target and labelling guidelines',
      (tester) async {
    final semantics = tester.ensureSemantics();
    await pump(tester, AddEntryScreen(plantId: 'p1'));
    picker.batches.add(['/pick/a.jpg', '/pick/b.jpg']);
    await tapButton(tester, 'Galeria');

    await expectTapTargetGuidelines(tester);
    expect(find.bySemanticsLabel('Foto 2 de 2'), findsOneWidget);
    expect(find.byTooltip('Remover foto 1'), findsOneWidget);
    semantics.dispose();
  });

  for (final (name, theme) in appThemes) {
    testWidgets('the photo section is readable in the $name theme',
        (tester) async {
      final semantics = tester.ensureSemantics();
      await pump(tester, AddEntryScreen(plantId: 'p1'), theme: theme);
      picker.batches.add(['/pick/a.jpg']);
      await tapButton(tester, 'Galeria');
      await paintBackground(tester);
      await expectReadableText(tester);
      semantics.dispose();
    });
  }
}
