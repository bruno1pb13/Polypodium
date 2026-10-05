import 'package:flutter/material.dart';

/// Text prefixed by an emoji (e.g. "💧 Irrigation"). Screen readers read only
/// [text], since the emoji just repeats what the text already says.
class EmojiText extends StatelessWidget {
  final String emoji;
  final String text;
  final String separator;
  final TextStyle? style;

  const EmojiText(
    this.emoji,
    this.text, {
    super.key,
    this.separator = ' ',
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final visible = emoji.isEmpty ? text : '$emoji$separator$text';
    return Semantics(
      label: text,
      excludeSemantics: true,
      child: Text(visible, style: style),
    );
  }
}
