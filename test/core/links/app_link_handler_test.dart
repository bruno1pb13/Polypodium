import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:polypodium/core/links/app_link_handler.dart';
import 'package:polypodium/features/plants/domain/plant_model.dart';
import 'package:polypodium/l10n/app_localizations.dart';

PlantModel _plant(String id, {DateTime? deletedAt}) => PlantModel(
      id: id,
      speciesId: 's',
      nickname: 'Samambaia',
      soilId: 'soil',
      acquisitionDate: DateTime(2024),
      createdAt: DateTime(2024),
      deletedAt: deletedAt,
    );

void main() {
  final plants = {
    'p1': _plant('p1'),
    'gone': _plant('gone', deletedAt: DateTime(2025)),
  };
  Future<PlantModel?> findPlant(String id) async => plants[id];
  Widget plantScreen(String id) => Scaffold(body: Text('plant $id'));

  late GlobalKey<NavigatorState> navigatorKey;

  Future<void> pump(WidgetTester tester) async {
    navigatorKey = GlobalKey<NavigatorState>();
    await tester.pumpWidget(MaterialApp(
      navigatorKey: navigatorKey,
      locale: const Locale('pt'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(body: Text('home')),
    ));
  }

  group('openScannedLabel', () {
    Future<void> scan(WidgetTester tester, String code) async {
      await openScannedLabel(navigatorKey.currentState!, code, findPlant,
          plantScreen: plantScreen);
      await tester.pumpAndSettle();
    }

    testWidgets('opens a plant of the active workspace', (tester) async {
      await pump(tester);
      await scan(tester, 'polypodium://plant/p1');
      expect(find.text('plant p1'), findsOneWidget);
    });

    testWidgets('also reads the widget form of the link', (tester) async {
      await pump(tester);
      await scan(tester, 'polypodium://plant?id=p1');
      expect(find.text('plant p1'), findsOneWidget);
    });

    testWidgets('says when the plant is not in this workspace', (tester) async {
      await pump(tester);
      await scan(tester, 'polypodium://plant/elsewhere');
      expect(find.text('home'), findsOneWidget);
      expect(find.text('Planta não encontrada neste espaço'), findsOneWidget);

      await scan(tester, 'polypodium://plant/gone');
      expect(find.text('Planta não encontrada neste espaço'), findsOneWidget);
      expect(find.textContaining('plant '), findsNothing);
    });

    testWidgets('rejects codes that are not plant labels', (tester) async {
      await pump(tester);
      for (final code in [
        'https://example.com',
        'polypodium://agenda',
        'polypodium://water?id=p1',
        'just text',
      ]) {
        await scan(tester, code);
        expect(find.text('Este código não é uma etiqueta do Polypodium'),
            findsOneWidget,
            reason: code);
      }
      expect(find.textContaining('plant '), findsNothing);
    });
  });

  group('AppLinkHandler', () {
    testWidgets('opens the plant of an incoming link', (tester) async {
      await pump(tester);
      AppLinkHandler(navigatorKey, findPlant, plantScreen: plantScreen)
          .handle(Uri.parse('polypodium://plant/p1'));
      await tester.pumpAndSettle();
      expect(find.text('plant p1'), findsOneWidget);
    });

    testWidgets('reports a plant that is not here', (tester) async {
      await pump(tester);
      AppLinkHandler(navigatorKey, findPlant, plantScreen: plantScreen)
          .handle(Uri.parse('polypodium://plant/elsewhere'));
      await tester.pumpAndSettle();
      expect(find.text('Planta não encontrada neste espaço'), findsOneWidget);
    });

    testWidgets('ignores background and foreign links', (tester) async {
      await pump(tester);
      final handler =
          AppLinkHandler(navigatorKey, findPlant, plantScreen: plantScreen);
      handler.handle(Uri.parse('polypodium://water?id=p1'));
      handler.handle(Uri.parse('polypodium://refresh'));
      handler.handle(Uri.parse('https://example.com/plant/p1'));
      handler.handle(null);
      await tester.pumpAndSettle();
      expect(find.text('home'), findsOneWidget);
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('waits for the navigator when the link launched the app',
        (tester) async {
      navigatorKey = GlobalKey<NavigatorState>();
      AppLinkHandler(navigatorKey, findPlant, plantScreen: plantScreen)
          .handle(Uri.parse('polypodium://plant/p1'));
      await tester.pumpWidget(MaterialApp(
        navigatorKey: navigatorKey,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(body: Text('home')),
      ));
      await tester.pumpAndSettle();
      expect(find.text('plant p1'), findsOneWidget);
    });
  });
}
