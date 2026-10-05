import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:polypodium/core/enums.dart';
import 'package:polypodium/features/entries/domain/entry_model.dart';
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
  final entries = [
    _entry('e1', 1, photoPath: '/nonexistent/a.jpg'),
    _entry('e2', 10, photoPath: '/nonexistent/b.jpg'),
    _entry('e3', 12),
  ];

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
}
