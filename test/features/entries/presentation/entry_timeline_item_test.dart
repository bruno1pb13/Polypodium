import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:polypodium/core/enums.dart';
import 'package:polypodium/core/widgets/fullscreen_image_viewer.dart';
import 'package:polypodium/features/entries/domain/entry_model.dart';
import 'package:polypodium/features/entries/presentation/widgets/entry_timeline_item.dart';
import 'package:polypodium/features/settings/presentation/providers/settings_providers.dart';
import 'package:polypodium/l10n/app_localizations.dart';

import '../../../helpers/accessibility.dart';

class _FakeTransparencyNotifier extends TransparencyEnabledNotifier {
  _FakeTransparencyNotifier([this.enabled = false]);
  final bool enabled;

  @override
  bool build() => enabled;
}

void main() {
  Future<void> pump(WidgetTester tester, EntryModel entry,
      {VoidCallback? onDelete,
      ThemeData? theme,
      bool transparent = false}) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        transparencyEnabledNotifierProvider
            .overrideWith(() => _FakeTransparencyNotifier(transparent)),
      ],
      child: MaterialApp(
        theme: theme,
        locale: const Locale('pt'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
            body: EntryTimelineItem(entry: entry, onDelete: onDelete)),
      ),
    ));
  }

  EntryModel entry(EntryType type,
          {String? extraData, double? numericValue, DateTime? date}) =>
      EntryModel(
        id: 'e1',
        plantId: 'p1',
        date: date ?? DateTime(2026, 1, 1),
        type: type,
        numericValue: numericValue,
        extraData: extraData,
        createdAt: DateTime(2026, 1, 1),
      );

  // extraData strings below are exactly what AddEntryScreen has always
  // written, so existing diaries keep rendering the same summaries.
  testWidgets('pest summary shows pest type and severity', (tester) async {
    await pump(
        tester,
        entry(EntryType.pest,
            extraData: '{"pestType":"Cochonilha"}', numericValue: 2));
    expect(find.text('🐛 Cochonilha · Moderada'), findsOneWidget);
  });

  testWidgets('single fertilizer product shows name and dose', (tester) async {
    await pump(
        tester,
        entry(EntryType.fertilizer,
            extraData: '{"products":[{"name":"NPK 10-10-10","dose":2.5}]}'));
    expect(find.text('🌱 NPK 10-10-10 · 2.5 ml'), findsOneWidget);
  });

  testWidgets('several fertilizer products show a count', (tester) async {
    await pump(
        tester,
        entry(EntryType.fertilizer,
            extraData:
                '{"products":[{"name":"NPK","dose":10.0},{"name":"Húmus"}]}'));
    expect(find.text('🌱 2 produtos'), findsOneWidget);
  });

  testWidgets('pruning summary shows the localized reason', (tester) async {
    await pump(
        tester, entry(EntryType.pruning, extraData: '{"reason":"limpeza"}'));
    expect(find.text('✂️ Limpeza'), findsOneWidget);
  });

  testWidgets('pesticide summary shows product and upcoming application',
      (tester) async {
    final date = DateTime.now().subtract(const Duration(days: 1));
    await pump(
        tester,
        entry(EntryType.pesticide,
            date: date,
            extraData: '{"products":[{"defensivoId":"d1",'
                '"name":"Óleo de neem","dose":"5 ml/L"}],"recurrenceDays":14}'));
    final next =
        DateFormat.yMd('pt').format(date.add(const Duration(days: 14)));
    expect(find.text('🧪 Óleo de neem · Próxima aplicação: $next'),
        findsOneWidget);
  });

  testWidgets('pesticide summary hides a past recurrence', (tester) async {
    await pump(
        tester,
        entry(EntryType.pesticide,
            extraData: '{"products":[{"defensivoId":"d1","name":"Neem"},'
                '{"defensivoId":"d2","name":"Calda"}],"recurrenceDays":7}'));
    expect(find.text('🧪 2 produtos'), findsOneWidget);
  });

  testWidgets('repotting summary shows pot and new soil', (tester) async {
    await pump(
        tester,
        entry(EntryType.repotting,
            extraData: '{"potDiameterCm":14.0,"potMaterial":"clay",'
                '"newSoilId":"s1","newSoilName":"Substrato"}'));
    expect(find.text('Replantio'), findsOneWidget);
    expect(find.text('🪴 Vaso de 14 cm · Barro · Substrato'), findsOneWidget);
  });

  testWidgets('repotting without details shows no badge', (tester) async {
    await pump(tester, entry(EntryType.repotting));
    expect(find.text('Replantio'), findsOneWidget);
    expect(find.textContaining('🪴'), findsNothing);
  });

  group('harvest', () {
    testWidgets('summary shows the quantity with its unit', (tester) async {
      await pump(tester,
          entry(EntryType.harvest, extraData: '{"quantity":1.5,"unit":"kg"}'));
      expect(find.text('Colheita'), findsOneWidget);
      expect(find.text('🧺 1,5 kg'), findsOneWidget);
      expect(find.text('Colheita durante a carência'), findsNothing);

      await pump(tester,
          entry(EntryType.harvest, extraData: '{"quantity":1,"unit":"units"}'));
      expect(find.text('🧺 1 unidade'), findsOneWidget);

      await pump(
          tester,
          entry(EntryType.harvest,
              extraData: '{"quantity":3,"unit":"bunches"}'));
      expect(find.text('🧺 3 maços'), findsOneWidget);

      // A unit from a newer version: just the number.
      await pump(tester,
          entry(EntryType.harvest, extraData: '{"quantity":2,"unit":"box"}'));
      expect(find.text('🧺 2'), findsOneWidget);
    });

    testWidgets('without a quantity shows no badge', (tester) async {
      await pump(tester, entry(EntryType.harvest, extraData: '{"unit":"g"}'));
      expect(find.text('Colheita'), findsOneWidget);
      expect(find.textContaining('🧺'), findsNothing);
    });

    testWidgets('a harvest during carência shows the warning', (tester) async {
      await pump(
          tester,
          entry(EntryType.harvest,
              extraData:
                  '{"quantity":300.0,"unit":"g","duringCarencia":true}'));
      expect(find.text('🧺 300 g'), findsOneWidget);
      expect(find.text('Colheita durante a carência'), findsOneWidget);

      await pump(tester,
          entry(EntryType.harvest, extraData: '{"duringCarencia":true}'));
      expect(find.text('Colheita durante a carência'), findsOneWidget);
    });

    testWidgets('the warning is read without its emoji', (tester) async {
      final semantics = tester.ensureSemantics();
      await pump(
          tester,
          entry(EntryType.harvest,
              extraData:
                  '{"quantity":300.0,"unit":"g","duringCarencia":true}'));
      expect(find.bySemanticsLabel('Colheita durante a carência'),
          findsOneWidget);
      expect(find.bySemanticsLabel('300 g'), findsOneWidget);
      expect(find.bySemanticsLabel(emojiLabel), findsNothing);
      semantics.dispose();
    });

    // On the glass style the plant screen uses.
    for (final (name, theme) in appThemes) {
      testWidgets('the warning is readable in the $name theme',
          (tester) async {
        final semantics = tester.ensureSemantics();
        await pump(
            tester,
            entry(EntryType.harvest,
                extraData: '{"quantity":2,"unit":"kg","duringCarencia":true}'),
            theme: theme,
            transparent: true);
        await expectReadableText(tester);
        semantics.dispose();
      });
    }
  });

  group('photos', () {
    EntryModel withPhotos(int count) => entry(EntryType.observation).copyWith(
          photoPath: '/nonexistent/1.jpg',
          extraPhotos: [
            for (var i = 2; i <= count; i++)
              EntryPhoto(id: 'ph$i', path: '/nonexistent/$i.jpg'),
          ],
        );

    testWidgets('a single photo shows as before', (tester) async {
      final semantics = tester.ensureSemantics();
      await pump(tester, withPhotos(1));
      expect(find.bySemanticsLabel('Foto de 01/01/2026'), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('Foto 1 de')), findsNothing);
      semantics.dispose();
    });

    testWidgets('several photos show as a strip that opens a swipeable '
        'viewer', (tester) async {
      final semantics = tester.ensureSemantics();
      await pump(tester, withPhotos(3), transparent: true);

      for (var i = 1; i <= 3; i++) {
        expect(find.bySemanticsLabel('Foto $i de 3 de 01/01/2026'),
            findsOneWidget);
      }
      await expectTapTargetGuidelines(tester);

      await tester.tap(find.bySemanticsLabel('Foto 2 de 3 de 01/01/2026'));
      await tester.pumpAndSettle();
      final viewer = tester
          .widget<FullscreenImageViewer>(find.byType(FullscreenImageViewer));
      expect(viewer.imagePaths,
          ['/nonexistent/1.jpg', '/nonexistent/2.jpg', '/nonexistent/3.jpg']);
      expect(find.text('2 de 3'), findsOneWidget);

      await tester.fling(find.byType(PageView), const Offset(-600, 0), 1000);
      await tester.pumpAndSettle();
      expect(find.text('3 de 3'), findsOneWidget);
      semantics.dispose();
    });

    for (final (name, theme) in appThemes) {
      for (final transparent in [true, false]) {
        testWidgets(
            'the strip is readable in the $name theme '
            '(transparency ${transparent ? 'on' : 'off'})', (tester) async {
          final semantics = tester.ensureSemantics();
          await pump(tester, withPhotos(2),
              theme: theme, transparent: transparent);
          await expectReadableText(tester);
          semantics.dispose();
        });
      }
    }
  });

  group('accessibility', () {
    testWidgets('the data badge is read without its emoji', (tester) async {
      final semantics = tester.ensureSemantics();
      await pump(
          tester,
          entry(EntryType.pest,
              extraData: '{"pestType":"Cochonilha"}', numericValue: 2));

      expect(find.bySemanticsLabel('Cochonilha · Moderada'), findsOneWidget);
      expect(find.bySemanticsLabel(emojiLabel), findsNothing);

      await pump(tester,
          entry(EntryType.repotting, extraData: '{"potMaterial":"fabric"}'));
      expect(find.bySemanticsLabel('Tecido'), findsOneWidget);
      expect(find.bySemanticsLabel(emojiLabel), findsNothing);
      semantics.dispose();
    });

    testWidgets('the health score badge is read without its emoji',
        (tester) async {
      final semantics = tester.ensureSemantics();
      await pump(tester, entry(EntryType.observation, numericValue: 4));

      expect(find.text('🟢 Saúde 4/5 — Boa'), findsOneWidget);
      expect(find.bySemanticsLabel('Saúde 4/5 — Boa'), findsOneWidget);
      semantics.dispose();
    });

    // Opaque mode (transparency off) draws on the theme surface colors.
    for (final (name, theme) in appThemes) {
      testWidgets('is readable without transparency in the $name theme',
          (tester) async {
        final semantics = tester.ensureSemantics();
        await pump(
            tester,
            entry(EntryType.pest,
                extraData: '{"pestType":"Cochonilha"}', numericValue: 2)
                .copyWith(note: 'Folhas com manchas'),
            onDelete: () {},
            theme: theme);
        expect(find.text('01/01/2026 00:00'), findsOneWidget);
        await expectReadableText(tester);
        semantics.dispose();
      });
    }

    testWidgets('the delete button is labelled', (tester) async {
      final semantics = tester.ensureSemantics();
      await pump(tester, entry(EntryType.observation), onDelete: () {});

      expect(find.byTooltip('Deletar'), findsOneWidget);
      await expectTapTargetGuidelines(tester);
      semantics.dispose();
    });
  });
}
