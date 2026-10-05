import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:polypodium/core/enums.dart';
import 'package:polypodium/features/entries/domain/entry_model.dart';
import 'package:polypodium/features/entries/presentation/widgets/entry_timeline_item.dart';
import 'package:polypodium/features/settings/presentation/providers/settings_providers.dart';
import 'package:polypodium/l10n/app_localizations.dart';

import '../../../helpers/accessibility.dart';

class _FakeTransparencyNotifier extends TransparencyEnabledNotifier {
  @override
  bool build() => false;
}

void main() {
  Future<void> pump(WidgetTester tester, EntryModel entry,
      {VoidCallback? onDelete}) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        transparencyEnabledNotifierProvider
            .overrideWith(_FakeTransparencyNotifier.new),
      ],
      child: MaterialApp(
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

    testWidgets('the delete button is labelled', (tester) async {
      final semantics = tester.ensureSemantics();
      await pump(tester, entry(EntryType.observation), onDelete: () {});

      expect(find.byTooltip('Deletar'), findsOneWidget);
      await expectTapTargetGuidelines(tester);
      semantics.dispose();
    });
  });
}
