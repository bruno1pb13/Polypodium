import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:polypodium/features/labels/data/label_pdf_output.dart';
import 'package:polypodium/features/labels/presentation/screens/plant_labels_screen.dart';
import 'package:polypodium/features/labels/presentation/widgets/plant_label_preview.dart';
import 'package:polypodium/features/locations/domain/location_model.dart';
import 'package:polypodium/features/locations/presentation/providers/locations_providers.dart';
import 'package:polypodium/features/plants/domain/plant_model.dart';
import 'package:polypodium/features/plants/presentation/providers/plants_providers.dart';
import 'package:polypodium/features/species/domain/species_model.dart';
import 'package:polypodium/features/species/presentation/providers/species_providers.dart';
import 'package:polypodium/l10n/app_localizations.dart';

import '../../helpers/accessibility.dart';

class _FakeOutput implements LabelPdfOutput {
  _FakeOutput({this.savesToFile = false});

  @override
  final bool savesToFile;

  final printed = <Uint8List>[];
  final exported = <Uint8List>[];

  @override
  Future<void> printPdf(Uint8List bytes, {required String name}) async =>
      printed.add(bytes);

  @override
  Future<String?> export(Uint8List bytes,
      {required String fileName, Rect? origin}) async {
    exported.add(bytes);
    return savesToFile ? '/tmp/$fileName' : null;
  }
}

class _Plants extends PlantsNotifier {
  @override
  Stream<List<PlantModel>> build() => Stream.value([
        for (final (id, name) in [('p1', 'Samambaia'), ('p2', 'Jiboia')])
          PlantModel(
            id: id,
            speciesId: 's1',
            nickname: name,
            soilId: 'soil',
            locationId: 'l1',
            acquisitionDate: DateTime(2024, 3, 12),
            createdAt: DateTime(2024),
          ),
      ]);
}

class _Species extends SpeciesNotifier {
  @override
  Stream<List<SpeciesModel>> build() => Stream.value([
        SpeciesModel(
          id: 's1',
          scientificName: 'Nephrolepis exaltata',
          popularName: 'Samambaia-americana',
          defaultIrrigationFrequencyDays: 3,
          recommendedSoilIds: const [],
          createdAt: DateTime(2024),
        ),
      ]);
}

class _Locations extends LocationsNotifier {
  @override
  Stream<List<LocationModel>> build() => Stream.value([
        LocationModel(id: 'l1', name: 'Varanda', createdAt: DateTime(2024)),
      ]);
}

void main() {
  late _FakeOutput output;

  Future<void> pump(WidgetTester tester, List<String> plantIds,
      {bool desktop = false}) async {
    tester.view.physicalSize = const Size(420, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    output = _FakeOutput(savesToFile: desktop);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        plantsNotifierProvider.overrideWith(_Plants.new),
        speciesNotifierProvider.overrideWith(_Species.new),
        locationsNotifierProvider.overrideWith(_Locations.new),
        labelPdfOutputProvider.overrideWithValue(output),
      ],
      child: MaterialApp(
        locale: const Locale('pt'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: PlantLabelsScreen(plantIds: plantIds),
      ),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('previews the first plant label', (tester) async {
    await pump(tester, ['p2', 'p1']);

    expect(find.text('2 etiquetas'), findsOneWidget);
    final preview =
        tester.widget<PlantLabelPreview>(find.byType(PlantLabelPreview));
    expect(preview.label.nickname, 'Jiboia');
    expect(preview.label.link, 'polypodium://plant/p2');
    expect(find.text('Jiboia'), findsOneWidget);
    expect(find.text('Nephrolepis exaltata'), findsOneWidget);
    expect(find.text('Varanda'), findsOneWidget);
    expect(find.text('Desde 12/03/2024'), findsNothing);
  });

  testWidgets('options change the preview and the page count', (tester) async {
    await pump(tester, ['p1', 'p2']);
    expect(find.text('Cabe em 1 folha A4'), findsOneWidget);

    await tester.tap(find.text('Mostrar localização'));
    await tester.tap(find.text('Mostrar data de aquisição'));
    await tester.pumpAndSettle();
    expect(find.text('Varanda'), findsNothing);
    expect(find.text('Desde 12/03/2024'), findsOneWidget);

    await tester.tap(find.text('10 por folha · 99 × 57 mm'));
    await tester.pumpAndSettle();
    final preview =
        tester.widget<PlantLabelPreview>(find.byType(PlantLabelPreview));
    expect(preview.options.preset.name, 'a4x10');
  });

  testWidgets('prints and shares the PDF', (tester) async {
    await pump(tester, ['p1', 'p2']);

    await tester.tap(find.text('Imprimir'));
    await tester.pumpAndSettle();
    expect(output.printed, hasLength(1));
    expect(String.fromCharCodes(output.printed.single.take(5)), '%PDF-');

    await tester.tap(find.text('Compartilhar PDF'));
    await tester.pumpAndSettle();
    expect(output.exported, hasLength(1));
  });

  testWidgets('saves the PDF on desktop', (tester) async {
    await pump(tester, ['p1'], desktop: true);
    expect(find.text('1 etiqueta'), findsOneWidget);

    await tester.tap(find.text('Salvar PDF'));
    await tester.pumpAndSettle();
    expect(output.exported, hasLength(1));
    expect(find.text('Etiquetas salvas em /tmp/polypodium-labels.pdf'),
        findsOneWidget);
  });

  testWidgets('meets the tap target and labelling guidelines', (tester) async {
    final semantics = tester.ensureSemantics();
    await pump(tester, ['p1']);
    await expectTapTargetGuidelines(tester);
    expect(
        find.bySemanticsLabel('Prévia da etiqueta: Samambaia'), findsOneWidget);
    semantics.dispose();
  });
}
