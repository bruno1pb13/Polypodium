import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/glass_colors.dart';

/// The plant's short code (`#3F9A1C`, as printed on its label), small and
/// muted next to its name in lists, to tell same-named plants apart. Read
/// by screen readers as "Code …".
class PlantShortCodeText extends StatelessWidget {
  final String code;
  final Color? color;
  final double fontSize;

  const PlantShortCodeText(
    this.code, {
    super.key,
    this.color,
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: context.l10n.plantShortCode(code),
      excludeSemantics: true,
      child: Text(
        '#$code',
        maxLines: 1,
        softWrap: false,
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: color ?? context.glass.fgFaint,
        ),
      ),
    );
  }
}
