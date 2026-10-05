import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../domain/plant_label.dart';

/// Lays [labels] out on A4 pages in the grid of [LabelOptions.preset], in
/// order, and returns the PDF. [acquiredText] words the acquisition date
/// line ("Since 03/12/2024"). Pure: no platform channels or assets.
Future<Uint8List> buildLabelsPdf(
  List<PlantLabel> labels, {
  required LabelOptions options,
  required String Function(DateTime date) acquiredText,
  String? title,
  bool compress = true,
}) {
  final preset = options.preset;
  final doc =
      pw.Document(title: title, creator: 'Polypodium', compress: compress);
  final pageFormat = PdfPageFormat(
    LabelSheetPreset.pageWidthMm * PdfPageFormat.mm,
    LabelSheetPreset.pageHeightMm * PdfPageFormat.mm,
  );
  final width = preset.widthMm * PdfPageFormat.mm;
  final height = preset.heightMm * PdfPageFormat.mm;
  final marginX =
      (pageFormat.width - preset.columns * width).clamp(0, double.infinity) / 2;
  final marginY =
      (pageFormat.height - preset.rows * height).clamp(0, double.infinity) / 2;

  for (var start = 0; start < labels.length; start += preset.perPage) {
    final page = labels.skip(start).take(preset.perPage).toList();
    doc.addPage(pw.Page(
      pageFormat: pageFormat.copyWith(
        marginLeft: marginX,
        marginRight: marginX,
        marginTop: marginY,
        marginBottom: marginY,
      ),
      build: (_) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          for (var row = 0; row * preset.columns < page.length; row++)
            pw.Row(children: [
              for (final label
                  in page.skip(row * preset.columns).take(preset.columns))
                pw.SizedBox(
                  width: width,
                  height: height,
                  child: _label(label, options, acquiredText, width, height),
                ),
            ]),
        ],
      ),
    ));
  }
  return doc.save();
}

pw.Widget _label(
  PlantLabel label,
  LabelOptions options,
  String Function(DateTime date) acquiredText,
  double width,
  double height,
) {
  // Also the QR code's quiet zone, about 4 modules.
  final padding = 4 * PdfPageFormat.mm;
  final qrSize =
      [height - 2 * padding, width * 0.42].reduce((a, b) => a < b ? a : b);
  final large = options.preset == LabelSheetPreset.a4x10;
  final body = large ? 9.0 : 7.0;

  pw.Widget line(String? text,
      {double? size,
      pw.FontWeight? weight,
      pw.FontStyle? style,
      bool muted = false}) {
    final value = pdfSafeText(text ?? '');
    if (value.isEmpty) return pw.SizedBox();
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 1.5),
      child: pw.Text(
        value,
        maxLines: 2,
        style: pw.TextStyle(
          fontSize: size ?? body,
          fontWeight: weight,
          fontStyle: style,
          color: muted ? PdfColors.grey800 : PdfColors.black,
        ),
      ),
    );
  }

  return pw.Container(
    padding: pw.EdgeInsets.all(padding),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: PdfColors.grey300, width: 0.3),
    ),
    child: pw.Row(
      children: [
        pw.BarcodeWidget(
          barcode: pw.Barcode.qrCode(
              errorCorrectLevel: pw.BarcodeQRCorrectionLevel.medium),
          data: label.link,
          width: qrSize,
          height: qrSize,
          drawText: false,
        ),
        pw.SizedBox(width: padding),
        pw.Expanded(
          child: pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              line(label.nickname,
                  size: large ? 13 : 9.5, weight: pw.FontWeight.bold),
              line(label.popularName, size: body),
              line(label.scientificName,
                  size: body, style: pw.FontStyle.italic),
              if (options.showLocation) line(label.location, muted: true),
              if (options.showAcquisitionDate)
                line(acquiredText(label.acquisitionDate), muted: true),
            ],
          ),
        ),
      ],
    ),
  );
}

const _replacements = {
  '‘': "'",
  '’': "'",
  '“': '"',
  '”': '"',
  '–': '-',
  '—': '-',
  '…': '...',
};

/// [text] reduced to what the PDF's built-in (Latin-1) fonts can draw:
/// typographic punctuation becomes ASCII and anything else outside Latin-1
/// (emoji, other scripts) is dropped.
String pdfSafeText(String text) {
  final out = StringBuffer();
  for (final rune in text.runes) {
    final char = String.fromCharCode(rune);
    final replacement = _replacements[char];
    if (replacement != null) {
      out.write(replacement);
    } else if (rune >= 0x20 && rune <= 0xff && (rune < 0x7f || rune > 0x9f)) {
      out.write(char);
    }
  }
  return out.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
}
