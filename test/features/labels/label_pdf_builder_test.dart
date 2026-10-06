import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:polypodium/features/labels/data/label_pdf_builder.dart';
import 'package:polypodium/features/labels/domain/plant_label.dart';

List<PlantLabel> _labels(int count) => [
      for (var i = 0; i < count; i++)
        PlantLabel(
          plantId: 'plant-$i',
          shortCode: 'AB12C$i',
          nickname: 'Samambaia $i',
          popularName: 'Samambaia-de-metro',
          scientificName: 'Nephrolepis exaltata',
          location: 'Varanda',
          acquisitionDate: DateTime(2024, 3, 12),
        ),
    ];

Future<String> _build(List<PlantLabel> labels, LabelOptions options) async =>
    latin1.decode(await buildLabelsPdf(
      labels,
      options: options,
      acquiredText: (d) => 'Desde ${d.day}/${d.month}/${d.year}',
      compress: false,
    ));

/// The words drawn on the pages (the PDF draws each word on its own).
String _text(String pdf) =>
    RegExp(r'\[\((.*?)\)\]TJ').allMatches(pdf).map((m) => m[1]).join(' ');

int _pageCount(String pdf) => RegExp(r'/Type\s*/Page\b').allMatches(pdf).length;

void main() {
  test('fills one page per preset grid', () async {
    for (final (count, preset, pages) in [
      (1, LabelSheetPreset.a4x24, 1),
      (24, LabelSheetPreset.a4x24, 1),
      (25, LabelSheetPreset.a4x24, 2),
      (10, LabelSheetPreset.a4x10, 1),
      (21, LabelSheetPreset.a4x10, 3),
    ]) {
      expect(preset.pagesFor(count), pages);
      final pdf = await _build(_labels(count), LabelOptions(preset: preset));
      expect(_pageCount(pdf), pages, reason: '$count on ${preset.name}');
    }
  });

  test('pages are A4', () async {
    final pdf = await _build(_labels(1), const LabelOptions());
    expect(pdf, contains('/MediaBox[0 0 595.27559 841.88976]'));
  });

  test('writes the plant texts and the optional lines', () async {
    final labels = _labels(2);
    final full = _text(await _build(labels,
        const LabelOptions(showLocation: true, showAcquisitionDate: true)));
    expect(full, contains('Samambaia 0'));
    expect(full, contains('Samambaia 1'));
    expect(full, contains('Nephrolepis exaltata'));
    expect(full, contains('Varanda'));
    expect(full, contains('Desde 12/3/2024'));
    expect(full, contains('#AB12C0'));
    expect(full, contains('#AB12C1'));

    final bare = _text(await _build(labels,
        const LabelOptions(showLocation: false, showAcquisitionDate: false)));
    expect(bare, contains('Samambaia 0'));
    expect(bare, isNot(contains('Varanda')));
    expect(bare, isNot(contains('Desde')));
  });

  test('draws names outside Latin-1 without failing', () async {
    final pdf = _text(await _build([
      PlantLabel(
        plantId: 'p',
        shortCode: 'P',
        nickname: 'Jiboia 🌿 “da sala”',
        acquisitionDate: DateTime(2024),
      ),
    ], const LabelOptions()));
    expect(pdf, '#P Jiboia "da sala"');
  });

  test('pdfSafeText keeps Portuguese accents', () {
    expect(pdfSafeText('Ação — coração 🌱'), 'Ação - coração');
  });

  test('labels link to the plant', () {
    expect(_labels(1).single.link, 'polypodium://plant/plant-0');
  });
}
