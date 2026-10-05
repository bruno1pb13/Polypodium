import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:polypodium/features/onboarding/presentation/screens/intro_screen.dart';
import 'package:polypodium/features/plants/presentation/providers/plants_providers.dart';
import 'package:polypodium/features/plants/presentation/screens/home_screen.dart';
import 'package:polypodium/features/settings/data/settings_repository.dart';
import 'package:polypodium/features/settings/presentation/providers/settings_providers.dart';
import 'package:polypodium/features/workspaces/domain/workspace_model.dart';
import 'package:polypodium/features/workspaces/presentation/providers/workspace_providers.dart';
import 'package:polypodium/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences prefs;

  Future<void> pump(WidgetTester tester) async {
    // Below the wide breakpoint, so the app shell opened at the end is just
    // the Home.
    tester.view.physicalSize = const Size(600, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    SharedPreferences.setMockInitialValues({'notifications_enabled': false});
    prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(ProviderScope(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(SettingsRepository(prefs)),
        activeWorkspaceProvider.overrideWithValue(Workspace.newLocal()),
        plantsWithSpeciesProvider.overrideWith((ref) async => const []),
      ],
      child: const MaterialApp(
        locale: Locale('pt'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: IntroScreen(),
      ),
    ));
    await tester.pumpAndSettle();
  }

  Future<void> next(WidgetTester tester) async {
    await tester.tap(find.text('Próximo'));
    await tester.pumpAndSettle();
  }

  testWidgets('walking through the pages marks the intro as seen',
      (tester) async {
    await pump(tester);
    expect(find.text('Bem-vindo ao Polypodium'), findsOneWidget);

    await next(tester);
    expect(find.text('Acompanhe suas plantas'), findsOneWidget);
    await next(tester);
    expect(find.text('Lembretes de rega'), findsOneWidget);
    expect(find.text('09:00'), findsOneWidget);

    await tester.tap(find.text('Ativar lembretes'));
    await tester.pumpAndSettle();
    expect(prefs.getBool('notifications_enabled'), isTrue);

    await next(tester);
    expect(find.text('Seus dados, em todo lugar'), findsOneWidget);
    expect(find.text('Próximo'), findsNothing);
    expect(prefs.getBool('intro_seen'), isNull);

    await tester.tap(find.text('Começar'));
    await tester.pumpAndSettle();
    expect(prefs.getBool('intro_seen'), isTrue);
    expect(find.byType(IntroScreen), findsNothing);
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Nenhuma planta cadastrada'), findsOneWidget);
  });

  testWidgets('skipping marks the intro as seen', (tester) async {
    await pump(tester);

    await tester.tap(find.text('Pular'));
    await tester.pumpAndSettle();
    expect(prefs.getBool('intro_seen'), isTrue);
    // Skipping is not an opt-in to reminders.
    expect(prefs.getBool('notifications_enabled'), isFalse);
    expect(find.byType(IntroScreen), findsNothing);
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
