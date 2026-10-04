import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:polypodium/core/enums.dart';
import 'package:polypodium/features/reminders/domain/reminder_model.dart';
import 'package:polypodium/features/reminders/presentation/providers/reminders_providers.dart';
import 'package:polypodium/features/reminders/presentation/widgets/plant_reminders_card.dart';
import 'package:polypodium/features/settings/presentation/providers/settings_providers.dart';
import 'package:polypodium/l10n/app_localizations.dart';

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

  Future<void> pump(WidgetTester tester, List<ReminderStatus> statuses) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        transparencyEnabledNotifierProvider
            .overrideWith(_FakeTransparencyNotifier.new),
        plantRemindersProvider('p1')
            .overrideWith((ref) => Stream.value(statuses)),
      ],
      child: const MaterialApp(
        locale: Locale('pt'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: PlantRemindersCard(plantId: 'p1')),
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
    ]);

    expect(find.text('Lembretes'), findsOneWidget);
    expect(find.text('Atrasado há 3 dias'), findsOneWidget);
    final next = midnight.add(const Duration(days: 10));
    final dd = next.day.toString().padLeft(2, '0');
    final mm = next.month.toString().padLeft(2, '0');
    expect(find.text('Próxima: $dd/$mm'), findsOneWidget);
    expect(find.text('Pausado'), findsOneWidget);
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
}
