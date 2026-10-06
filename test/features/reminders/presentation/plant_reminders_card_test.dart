import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:polypodium/core/enums.dart';
import 'package:polypodium/features/plants/domain/plant_model.dart';
import 'package:polypodium/features/reminders/domain/reminder_model.dart';
import 'package:polypodium/features/reminders/presentation/providers/reminders_providers.dart';
import 'package:polypodium/features/reminders/presentation/widgets/plant_reminders_card.dart';
import 'package:polypodium/features/settings/presentation/providers/settings_providers.dart';
import 'package:polypodium/l10n/app_localizations.dart';

import '../../../helpers/accessibility.dart';

class _FakeTransparencyNotifier extends TransparencyEnabledNotifier {
  @override
  bool build() => true;
}

void main() {
  final today = DateTime.now();
  final midnight = DateTime(today.year, today.month, today.day);

  ReminderStatus status(EntryType type, int intervalDays,
          {DateTime? lastDoneAt, bool enabled = true}) =>
      ReminderStatus(
        reminder: ReminderModel(
          id: type.name,
          plantId: 'p1',
          entryType: type,
          intervalDays: intervalDays,
          enabled: enabled,
          createdAt: midnight.subtract(const Duration(days: 400)),
        ),
        lastDoneAt: lastDoneAt,
      );

  PlantModel plant({DateTime? lastPesticideAt, int? pesticideDays}) =>
      PlantModel(
        id: 'p1',
        speciesId: 's1',
        nickname: 'Ficus',
        soilId: 'soil1',
        acquisitionDate: midnight,
        lastPesticideAppliedAt: lastPesticideAt,
        pesticideReapplicationDays: pesticideDays,
        createdAt: midnight,
      );

  Future<void> pump(WidgetTester tester, List<ReminderStatus> statuses,
      {PlantModel? forPlant}) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        transparencyEnabledNotifierProvider
            .overrideWith(_FakeTransparencyNotifier.new),
        plantRemindersProvider('p1')
            .overrideWith((ref) => Stream.value(statuses)),
      ],
      child: MaterialApp(
        locale: const Locale('pt'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: PlantRemindersCard(plant: forPlant ?? plant())),
      ),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('shows overdue, upcoming and paused reminders', (tester) async {
    await pump(tester, [
      status(EntryType.fertilizer, 30,
          lastDoneAt: midnight.subtract(const Duration(days: 33))),
      status(EntryType.pruning, 10, lastDoneAt: midnight),
      status(EntryType.observation, 7, enabled: false),
      status(EntryType.repotting, 365, lastDoneAt: midnight),
    ]);

    expect(find.text('Lembretes'), findsOneWidget);
    expect(find.text('Atrasado há 3 dias'), findsOneWidget);
    final next = midnight.add(const Duration(days: 10));
    final dd = next.day.toString().padLeft(2, '0');
    final mm = next.month.toString().padLeft(2, '0');
    expect(find.text('Próxima: $dd/$mm'), findsOneWidget);
    expect(find.text('Pausado'), findsOneWidget);
    expect(find.text('Replantio'), findsOneWidget);
    // Every supported type already has a reminder: nothing left to add.
    expect(find.byTooltip('Adicionar lembrete'), findsNothing);
  });

  testWidgets('empty state offers to add one', (tester) async {
    await pump(tester, const []);

    expect(find.byTooltip('Adicionar lembrete'), findsOneWidget);
    await tester.tap(find.byTooltip('Adicionar lembrete'));
    await tester.pumpAndSettle();
    expect(find.byType(ReminderDialog), findsOneWidget);
  });

  testWidgets('lists the pesticide reapplication of the latest entry',
      (tester) async {
    await pump(tester, const [],
        forPlant: plant(
            lastPesticideAt: midnight.subtract(const Duration(days: 5)),
            pesticideDays: 15));

    expect(find.text('Defensivos'), findsOneWidget);
    final next = midnight.add(const Duration(days: 10));
    final dd = next.day.toString().padLeft(2, '0');
    final mm = next.month.toString().padLeft(2, '0');
    expect(find.text('Próxima: $dd/$mm'), findsOneWidget);
    expect(find.textContaining('A cada 15 dias'), findsOneWidget);
    // Not the empty state anymore.
    expect(find.textContaining('Nenhum lembrete'), findsNothing);

    // It is managed from the diary: tapping explains that and offers to
    // record a new application.
    await tester.tap(find.text('Defensivos'));
    await tester.pumpAndSettle();
    expect(find.text('Reaplicação de defensivo'), findsOneWidget);
    expect(find.byType(ReminderDialog), findsNothing);
    expect(find.text('Registrar aplicação'), findsOneWidget);
    await tester.tap(find.text('Fechar'));
    await tester.pumpAndSettle();
    expect(find.text('Reaplicação de defensivo'), findsNothing);
  });

  testWidgets('an overdue pesticide reapplication shows as overdue',
      (tester) async {
    await pump(tester, const [],
        forPlant: plant(
            lastPesticideAt: midnight.subtract(const Duration(days: 9)),
            pesticideDays: 7));

    expect(find.text('Atrasado há 2 dias'), findsOneWidget);
  });

  group('accessibility', () {
    List<ReminderStatus> statuses() => [
          status(EntryType.fertilizer, 30,
              lastDoneAt: midnight.subtract(const Duration(days: 33))),
          status(EntryType.pruning, 10, lastDoneAt: midnight),
        ];

    testWidgets('rows are read by type, not by emoji', (tester) async {
      final semantics = tester.ensureSemantics();
      await pump(tester, statuses());

      expect(find.bySemanticsLabel(emojiLabel), findsNothing);
      expect(find.bySemanticsLabel(RegExp('^Fertilização')), findsOneWidget);
      await expectTapTargetGuidelines(tester);
      semantics.dispose();
    });

    testWidgets('lays out without overflow at text scale 2', (tester) async {
      tester.view.physicalSize = const Size(400, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      setTextScale(tester, 2);

      await pump(tester, statuses());
      expect(tester.takeException(), isNull);
    });
  });
}
