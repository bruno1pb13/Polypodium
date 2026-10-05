import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' show Rect;

import 'package:file_selector/file_selector.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

/// Where a labels PDF goes: the system print dialog, or out as a file.
abstract interface class LabelPdfOutput {
  /// Whether [export] saves to a file (desktop) rather than sharing.
  bool get savesToFile;

  Future<void> printPdf(Uint8List bytes, {required String name});

  /// Shares the PDF (mobile) or asks where to save it (desktop). Returns the
  /// saved path, or null when shared or cancelled.
  Future<String?> export(Uint8List bytes,
      {required String fileName, Rect? origin});
}

class PlatformLabelPdfOutput implements LabelPdfOutput {
  const PlatformLabelPdfOutput();

  @override
  bool get savesToFile => !(Platform.isAndroid || Platform.isIOS);

  @override
  Future<void> printPdf(Uint8List bytes, {required String name}) =>
      Printing.layoutPdf(onLayout: (_) async => bytes, name: name);

  @override
  Future<String?> export(Uint8List bytes,
      {required String fileName, Rect? origin}) async {
    if (!savesToFile) {
      final dir = await getTemporaryDirectory();
      final file = File(p.join(dir.path, fileName));
      await file.writeAsBytes(bytes);
      await SharePlus.instance.share(ShareParams(
        files: [XFile(file.path, mimeType: 'application/pdf')],
        sharePositionOrigin: origin,
      ));
      return null;
    }
    final location = await getSaveLocation(
      suggestedName: fileName,
      acceptedTypeGroups: const [
        XTypeGroup(label: 'PDF', extensions: ['pdf']),
      ],
    );
    if (location == null) return null;
    await File(location.path).writeAsBytes(bytes);
    return location.path;
  }
}

final labelPdfOutputProvider =
    Provider<LabelPdfOutput>((ref) => const PlatformLabelPdfOutput());
