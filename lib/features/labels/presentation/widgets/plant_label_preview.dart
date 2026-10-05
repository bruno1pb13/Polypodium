import 'package:flutter/material.dart';
import 'package:qr/qr.dart';

import '../../../../core/l10n/l10n.dart';
import '../../data/label_pdf_builder.dart';
import '../../domain/plant_label.dart';

/// One label as it prints: laid out in PDF points (like [buildLabelsPdf])
/// and scaled to the available width. Paper colours, whatever the theme.
class PlantLabelPreview extends StatelessWidget {
  const PlantLabelPreview({
    super.key,
    required this.label,
    required this.options,
    required this.acquiredText,
  });

  final PlantLabel label;
  final LabelOptions options;
  final String Function(DateTime date) acquiredText;

  static const _pointsPerMm = 72 / 25.4;

  @override
  Widget build(BuildContext context) {
    final preset = options.preset;
    final width = preset.widthMm * _pointsPerMm;
    final height = preset.heightMm * _pointsPerMm;
    const padding = 4 * _pointsPerMm;
    final qrSize =
        [height - 2 * padding, width * 0.42].reduce((a, b) => a < b ? a : b);
    final large = preset == LabelSheetPreset.a4x10;
    final body = large ? 9.0 : 7.0;

    Widget line(String? text,
        {required double size,
        FontWeight? weight,
        FontStyle? style,
        bool muted = false}) {
      final value = pdfSafeText(text ?? '');
      if (value.isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(bottom: 1.5),
        child: Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: size,
            height: 1.15,
            fontWeight: weight,
            fontStyle: style,
            color: muted ? const Color(0xFF424242) : Colors.black,
          ),
        ),
      );
    }

    return Semantics(
      container: true,
      image: true,
      label: '${context.l10n.labelsPreview}: ${label.nickname}',
      excludeSemantics: true,
      child: AspectRatio(
        aspectRatio: width / height,
        child: FittedBox(
          child: MediaQuery.withNoTextScaling(
            child: Container(
              width: width,
              height: height,
              padding: const EdgeInsets.all(padding),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(2),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 4),
                ],
              ),
              child: Row(
                children: [
                  SizedBox.square(
                    dimension: qrSize,
                    child: CustomPaint(painter: QrPainter(label.link)),
                  ),
                  const SizedBox(width: padding),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        line(label.nickname,
                            size: large ? 13 : 9.5, weight: FontWeight.bold),
                        line(label.popularName, size: body),
                        line(label.scientificName,
                            size: body, style: FontStyle.italic),
                        if (options.showLocation)
                          line(label.location, size: body, muted: true),
                        if (options.showAcquisitionDate)
                          line(acquiredText(label.acquisitionDate),
                              size: body, muted: true),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Draws [data] as a QR code (error correction M, as on the printed label).
class QrPainter extends CustomPainter {
  QrPainter(this.data)
      : _image = QrImage(QrCode.fromData(
            data: data, errorCorrectLevel: QrErrorCorrectLevel.M));

  final String data;
  final QrImage _image;

  @override
  void paint(Canvas canvas, Size size) {
    final count = _image.moduleCount;
    final module = size.shortestSide / count;
    final paint = Paint()..color = Colors.black;
    for (var row = 0; row < count; row++) {
      for (var col = 0; col < count; col++) {
        if (_image.isDark(row, col)) {
          canvas.drawRect(
            // Slight overlap so antialiasing leaves no seams between modules.
            Rect.fromLTWH(
                col * module, row * module, module + 0.3, module + 0.3),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(QrPainter oldDelegate) => oldDelegate.data != data;
}
