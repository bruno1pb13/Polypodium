import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:polypodium/core/enums.dart';
import 'package:polypodium/core/widgets/fullscreen_image_viewer.dart';
import 'package:polypodium/features/entries/domain/entry_model.dart';
import 'package:polypodium/features/plants/domain/plant_photos.dart';
import 'package:polypodium/features/plants/presentation/screens/photo_comparison_screen.dart';
import 'package:polypodium/features/plants/presentation/widgets/plant_photos_sliver.dart';
import 'package:polypodium/features/settings/presentation/providers/settings_providers.dart';
import 'package:polypodium/l10n/app_localizations.dart';

import '../../../../helpers/accessibility.dart';

class _FakeTransparencyNotifier extends TransparencyEnabledNotifier {
  @override
  bool build() => true;
}

EntryModel _entry(String id, int day, {String? photoPath}) => EntryModel(
      id: id,
      plantId: 'p1',
      date: DateTime(2026, 3, day),
      type: EntryType.observation,
      photoPath: photoPath,
      createdAt: DateTime(2026, 3, day),
    );

void main() {
  var entries = <EntryModel>[];
  setUp(() => entries = [
        _entry('e1', 1, photoPath: '/nonexistent/a.jpg'),
        _entry('e2', 10, photoPath: '/nonexistent/b.jpg'),
        _entry('e3', 12),
      ]);

  Future<void> pump(WidgetTester tester,
      {String? coverPhotoId,
      ValueChanged<String?>? onSetCover,
      ThemeData? theme}) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        transparencyEnabledNotifierProvider
            .overrideWith(_FakeTransparencyNotifier.new),
      ],
      child: MaterialApp(
        theme: theme,
        locale: const Locale('pt'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: CustomScrollView(slivers: [
            PlantPhotosSliver(
              entries: entries,
              coverPhotoId: coverPhotoId,
              onSetCover: onSetCover,
            ),
          ]),
        ),
      ),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('shows every photo of an entry; a tap swipes through all',
      (tester) async {
    final semantics = tester.ensureSemantics();
    entries = [
      _entry('e1', 1, photoPath: '/nonexistent/a.jpg'),
      _entry('e2', 10, photoPath: '/nonexistent/b.jpg').copyWith(extraPhotos: [
        const EntryPhoto(id: 'ph', path: '/nonexistent/c.jpg')
      ]),
    ];
    await pump(tester);

    expect(find.bySemanticsLabel(RegExp('Foto (de capa )?de 10/03/2026')),
        findsNWidgets(2));
    await tester.tap(find.bySemanticsLabel('Foto de 01/03/2026'));
    await tester.pumpAndSettle();
    final viewer = tester
        .widget<FullscreenImageViewer>(find.byType(FullscreenImageViewer));
    expect(viewer.imagePaths, [
      '/nonexistent/a.jpg',
      '/nonexistent/b.jpg',
      '/nonexistent/c.jpg',
    ]);
    expect(viewer.initialIndex, 0);
    expect(find.text('1 de 3'), findsOneWidget);
    semantics.dispose();
  });

  group('cover', () {
    testWidgets('marks the latest photo without a pick', (tester) async {
      final semantics = tester.ensureSemantics();
      await pump(tester);

      expect(find.text('Capa'), findsOneWidget);
      expect(
          find.bySemanticsLabel('Foto de capa de 10/03/2026'), findsOneWidget);
      expect(find.bySemanticsLabel('Foto de 01/03/2026'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('marks the picked photo', (tester) async {
      final semantics = tester.ensureSemantics();
      await pump(tester, coverPhotoId: 'e1');

      expect(
          find.bySemanticsLabel('Foto de capa de 01/03/2026'), findsOneWidget);
      expect(find.bySemanticsLabel('Foto de 10/03/2026'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('long-press picks a photo as cover', (tester) async {
      final picks = <String?>[];
      await pump(tester, onSetCover: picks.add);

      await tester.longPress(find.bySemanticsLabel('Foto de 01/03/2026'));
      await tester.pumpAndSettle();
      // The latest photo is only the cover by default.
      expect(find.text('Usar a foto mais recente como capa'), findsNothing);
      await tester.tap(find.text('Definir como capa'));
      await tester.pumpAndSettle();
      expect(picks, ['e1']);
    });

    testWidgets('the picked cover can go back to the latest photo',
        (tester) async {
      final picks = <String?>[];
      await pump(tester, coverPhotoId: 'e1', onSetCover: picks.add);

      await tester
          .longPress(find.bySemanticsLabel('Foto de capa de 01/03/2026'));
      await tester.pumpAndSettle();
      expect(find.text('Definir como capa'), findsNothing);
      await tester.tap(find.text('Usar a foto mais recente como capa'));
      await tester.pumpAndSettle();
      expect(picks, [null]);
    });

    testWidgets('meets the tap target and labelling guidelines',
        (tester) async {
      final semantics = tester.ensureSemantics();
      await pump(tester, onSetCover: (_) {});
      await expectTapTargetGuidelines(tester);
      expect(
        tester.getSemantics(find.bySemanticsLabel('Foto de 01/03/2026')),
        matchesSemantics(
          label: 'Foto de 01/03/2026',
          isButton: true,
          isImage: true,
          hasTapAction: true,
          hasLongPressAction: true,
        ),
      );
      semantics.dispose();
    });
  });

  group('comparison', () {
    testWidgets('compares a photo with the first one', (tester) async {
      await pump(tester);

      await tester.longPress(find.bySemanticsLabel('Foto de 01/03/2026'));
      await tester.pumpAndSettle();
      // The first photo has nothing before it.
      expect(find.text('Comparar com a primeira foto'), findsNothing);
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      await tester
          .longPress(find.bySemanticsLabel('Foto de capa de 10/03/2026'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Comparar com a primeira foto'));
      await tester.pumpAndSettle();

      expect(find.byType(PhotoComparisonScreen), findsOneWidget);
      expect(find.text('Antes · 01/03/2026'), findsOneWidget);
      expect(find.text('Depois · 10/03/2026'), findsOneWidget);
    });

    testWidgets('compares with another photo picked next, in date order',
        (tester) async {
      await pump(tester);

      await tester
          .longPress(find.bySemanticsLabel('Foto de capa de 10/03/2026'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Comparar com outra foto'));
      await tester.pumpAndSettle();
      expect(find.text('Escolha outra foto para comparar'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Foto de 01/03/2026'));
      await tester.pumpAndSettle();
      final screen = tester
          .widget<PhotoComparisonScreen>(find.byType(PhotoComparisonScreen));
      expect(screen.before.photo.id, 'e1');
      expect(screen.after.photo.id, 'e2');

      Navigator.of(tester.element(find.byType(PhotoComparisonScreen))).pop();
      await tester.pumpAndSettle();
      expect(find.text('Escolha outra foto para comparar'), findsNothing);
    });

    testWidgets('picking another photo can be cancelled', (tester) async {
      await pump(tester);
      await tester.longPress(find.bySemanticsLabel('Foto de 01/03/2026'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Comparar com outra foto'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(find.text('Escolha outra foto para comparar'), findsNothing);
    });

    for (final (name, theme) in appThemes) {
      testWidgets('the prompt is readable in the $name theme', (tester) async {
        final semantics = tester.ensureSemantics();
        await pump(tester, theme: theme);
        await tester.longPress(find.bySemanticsLabel('Foto de 01/03/2026'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Comparar com outra foto'));
        await tester.pumpAndSettle();

        await expectReadableText(tester);
        await expectTapTargetGuidelines(tester);
        semantics.dispose();
      });
    }
  });

  group('PhotoComparisonScreen', () {
    PlantPhoto photo(String id, int day) {
      final entry = _entry(id, day, photoPath: '/nonexistent/$id.jpg');
      return (photo: entry.photos.single, entry: entry);
    }

    Future<void> pumpScreen(WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        locale: const Locale('pt'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        // Given newest first: still shown oldest first.
        home: PhotoComparisonScreen(a: photo('new', 20), b: photo('old', 2)),
      ));
      await tester.pumpAndSettle();
    }

    testWidgets(
        'shows both photos with their dates, side by side or '
        'with a divider', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpScreen(tester);

      expect(find.text('Antes e depois'), findsOneWidget);
      expect(find.text('Antes · 02/03/2026'), findsOneWidget);
      expect(find.text('Depois · 20/03/2026'), findsOneWidget);
      expect(find.bySemanticsLabel('Antes · 02/03/2026'), findsOneWidget);
      expect(tester.getTopLeft(find.text('Antes · 02/03/2026')).dx,
          lessThan(tester.getTopLeft(find.text('Depois · 20/03/2026')).dx));

      await tester.tap(find.text('Deslizante'));
      await tester.pumpAndSettle();
      expect(find.text('Antes · 02/03/2026'), findsOneWidget);
      expect(find.text('Depois · 20/03/2026'), findsOneWidget);

      final divider = find.bySemanticsLabel('Divisória entre as fotos');
      expect(tester.getSemantics(divider).value, '50%');
      // As a screen reader's "increase".
      tester
          .widget<Semantics>(find.byWidgetPredicate((w) =>
              w is Semantics &&
              w.properties.label == 'Divisória entre as fotos'))
          .properties
          .onIncrease!();
      await tester.pumpAndSettle();
      expect(tester.getSemantics(divider).value, '60%');

      await tester.drag(
          find.byIcon(Icons.compare_arrows), const Offset(-2000, 0));
      await tester.pumpAndSettle();
      expect(tester.getSemantics(divider).value, '0%');
      semantics.dispose();
    });

    testWidgets('meets the accessibility guidelines', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpScreen(tester);
      await expectReadableText(tester);
      await expectTapTargetGuidelines(tester);

      await tester.tap(find.text('Deslizante'));
      await tester.pumpAndSettle();
      await expectTapTargetGuidelines(tester);
      semantics.dispose();
    });

    testWidgets('lays out without overflow at text scale 2', (tester) async {
      setTextScale(tester, 2);
      tester.view.physicalSize = const Size(360, 720);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await pumpScreen(tester);
      expect(tester.takeException(), isNull);
    });
  });
}
