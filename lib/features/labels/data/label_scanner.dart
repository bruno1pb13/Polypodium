import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../presentation/screens/label_scanner_screen.dart';

/// Reads a code with the camera.
abstract interface class LabelScanner {
  /// Whether this device can scan at all (mobile_scanner has no Windows or
  /// Linux implementation).
  bool get isSupported;

  /// The text of the first code read, or null if the user backed out.
  Future<String?> scan(BuildContext context);
}

class CameraLabelScanner implements LabelScanner {
  const CameraLabelScanner();

  static const platforms = {
    TargetPlatform.android,
    TargetPlatform.iOS,
    TargetPlatform.macOS,
  };

  @override
  bool get isSupported => !kIsWeb && platforms.contains(defaultTargetPlatform);

  @override
  Future<String?> scan(BuildContext context) => Navigator.push<String>(
        context,
        MaterialPageRoute(builder: (_) => const LabelScannerScreen()),
      );
}

final labelScannerProvider =
    Provider<LabelScanner>((ref) => const CameraLabelScanner());
