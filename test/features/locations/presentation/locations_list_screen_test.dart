import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:polypodium/core/location/location_provider.dart';
import 'package:polypodium/core/location/location_service.dart';
import 'package:polypodium/core/sync/sync_providers.dart';
import 'package:polypodium/features/locations/domain/location_model.dart';
import 'package:polypodium/features/locations/presentation/providers/locations_providers.dart';
import 'package:polypodium/features/locations/presentation/screens/add_edit_location_screen.dart';
import 'package:polypodium/features/locations/presentation/screens/locations_list_screen.dart';
import 'package:polypodium/features/settings/presentation/providers/settings_providers.dart';
import 'package:polypodium/l10n/app_localizations.dart';

class _FakeTransparencyNotifier extends TransparencyEnabledNotifier {
  @override
  bool build() => true;
}

class _FakeLocationsNotifier extends LocationsNotifier {
  _FakeLocationsNotifier(this.locations, this.saved, this.deleted);
  final List<LocationModel> locations;
  final List<LocationModel> saved;
  final List<String> deleted;

  @override
  Stream<List<LocationModel>> build() => Stream.value(locations);

  @override
  Future<void> save(LocationModel location) async => saved.add(location);

  @override
  Future<void> delete(String locationId) async => deleted.add(locationId);
}

class _FakeLocationService implements ILocationService {
  @override
  Future<DeviceCoordinates> getCurrentPosition() async =>
      const DeviceCoordinates(latitude: -23.5505, longitude: -46.6333);
}

void main() {
  final locations = [
    LocationModel(
      id: 'l1',
      name: 'Varanda',
      description: 'Sol da manhã',
      createdAt: DateTime(2024, 1, 1),
    ),
    LocationModel(id: 'l2', name: 'Sala', createdAt: DateTime(2024, 1, 2)),
  ];

  late List<LocationModel> saved;
  late List<String> deleted;

  Future<void> pump(WidgetTester tester, List<LocationModel> locations) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    saved = [];
    deleted = [];
    await tester.pumpWidget(ProviderScope(
      overrides: [
        transparencyEnabledNotifierProvider
            .overrideWith(_FakeTransparencyNotifier.new),
        locationsNotifierProvider.overrideWith(
            () => _FakeLocationsNotifier(locations, saved, deleted)),
        pushCursorToServerProvider.overrideWith((ref) async => null),
        locationServiceProvider.overrideWithValue(_FakeLocationService()),
      ],
      child: const MaterialApp(
        locale: Locale('pt'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: LocationsListScreen(),
      ),
    ));
    await tester.pumpAndSettle();
  }

  Future<void> search(WidgetTester tester, String query) async {
    await tester.enterText(find.byType(TextField), query);
    // Past the search debounce.
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
  }

  Finder field(String label) => find.widgetWithText(TextFormField, label);

  testWidgets('lists the locations by name and searches them', (tester) async {
    await pump(tester, locations);

    expect(find.text('Varanda'), findsOneWidget);
    expect(find.text('Sol da manhã'), findsOneWidget);
    expect(find.text('Sala'), findsOneWidget);
    expect(tester.getTopLeft(find.text('Sala')).dy,
        lessThan(tester.getTopLeft(find.text('Varanda')).dy));

    await search(tester, 'varan');
    expect(find.text('Varanda'), findsOneWidget);
    expect(find.text('Sala'), findsNothing);

    await search(tester, 'quintal');
    expect(find.text('Nenhuma localização encontrada'), findsOneWidget);
  });

  testWidgets('shows the empty state without locations', (tester) async {
    await pump(tester, []);
    expect(find.text('Nenhuma localização cadastrada'), findsOneWidget);
  });

  testWidgets('creates a location with the device coordinates', (tester) async {
    await pump(tester, locations);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.text('Nova localização'), findsOneWidget);

    await tester.enterText(field('Latitude'), '91');
    await tester.tap(find.text('Adicionar localização'));
    await tester.pumpAndSettle();
    expect(find.text('Campo obrigatório'), findsOneWidget);
    expect(find.text('Fora do intervalo [-90.0, 90.0]'), findsOneWidget);
    expect(saved, isEmpty);

    await tester.enterText(field('Nome *'), ' Quintal ');
    await tester.enterText(field('Descrição'), 'Meia-sombra');
    await tester.tap(find.text('Usar localização atual'));
    await tester.pumpAndSettle();
    expect(find.text('-23.550500'), findsOneWidget);
    expect(find.text('-46.633300'), findsOneWidget);

    await tester.tap(find.text('Adicionar localização'));
    await tester.pumpAndSettle();

    final location = saved.single;
    expect(location.name, 'Quintal');
    expect(location.description, 'Meia-sombra');
    expect(location.latitude, -23.5505);
    expect(location.longitude, -46.6333);
    expect(find.byType(AddEditLocationScreen), findsNothing);
  });

  testWidgets('edits a location from its edit button', (tester) async {
    await pump(tester, locations);

    await tester.tap(find.byIcon(Icons.edit_outlined).last);
    await tester.pumpAndSettle();
    expect(find.text('Editar localização'), findsOneWidget);

    await tester.enterText(field('Nome *'), 'Varanda dos fundos');
    await tester.tap(find.text('Salvar alterações'));
    await tester.pumpAndSettle();

    final location = saved.single;
    expect(location.id, 'l1');
    expect(location.name, 'Varanda dos fundos');
    expect(location.description, 'Sol da manhã');
    expect(location.createdAt, DateTime(2024, 1, 1));
  });

  testWidgets('deletes a location after confirming', (tester) async {
    await pump(tester, locations);

    await tester.tap(find.byIcon(Icons.delete_outline).first);
    await tester.pumpAndSettle();
    expect(find.text('Deletar localização?'), findsOneWidget);
    await tester.tap(find.text('Deletar'));
    await tester.pumpAndSettle();
    expect(deleted, ['l2']);
  });
}
