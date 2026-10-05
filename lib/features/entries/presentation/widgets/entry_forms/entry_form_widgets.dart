import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/l10n/l10n.dart';
import '../../../../../core/widgets/emoji_text.dart';

// ---------------------------------------------------------------------------
// Shared small widgets of the new entry form
// ---------------------------------------------------------------------------

class EntrySectionTitle extends StatelessWidget {
  final String emoji;
  final String label;

  const EntrySectionTitle(
      {super.key, required this.emoji, required this.label});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: EmojiText(
        emoji,
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class EntryHintText extends StatelessWidget {
  final String text;
  const EntryHintText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.7),
        fontSize: 12,
      ),
    );
  }
}

class EntryNumericField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String suffix;
  final String hint;
  final bool hasError;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  const EntryNumericField({
    super.key,
    required this.controller,
    required this.label,
    required this.suffix,
    required this.hint,
    this.hasError = false,
    this.errorText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
      ],
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: hasError ? Colors.redAccent : Colors.white70,
        ),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
        suffixText: suffix,
        suffixStyle: const TextStyle(color: Colors.white54),
        errorText: errorText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: hasError ? Colors.redAccent : Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
      ),
    );
  }
}

class EntryTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool hasError;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  const EntryTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.hasError = false,
    this.errorText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      textCapitalization: TextCapitalization.sentences,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: hasError ? Colors.redAccent : Colors.white70,
        ),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
        errorText: errorText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: hasError ? Colors.redAccent : Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
      ),
    );
  }
}

/// One option of a single-choice list (intensity, severity, ...).
typedef EntryOption = ({int value, String label, String description});

class EntrySelectionRow extends StatelessWidget {
  final bool selected;
  final String label;
  final String description;
  final VoidCallback onTap;

  const EntrySelectionRow({
    super.key,
    required this.selected,
    required this.label,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      button: true,
      selected: selected,
      inMutuallyExclusiveGroup: true,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)
                : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.white24,
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: selected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.white54,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight:
                            selected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "+ Add ..." pill button below a dynamic list of product rows.
class EntryAddRowButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const EntryAddRowButton(
      {super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.add, size: 18, color: Colors.white70),
      label: Text(
        label,
        style: const TextStyle(color: Colors.white70, fontSize: 13),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.white24),
        ),
      ),
    );
  }
}

/// Remove button of a product row, shown when there is more than one row.
class EntryRemoveRowButton extends StatelessWidget {
  final VoidCallback onPressed;

  const EntryRemoveRowButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: IconButton(
        onPressed: onPressed,
        tooltip: context.l10n.removeAction,
        icon: const Icon(Icons.remove_circle_outline,
            color: Colors.white54, size: 22),
      ),
    );
  }
}

class EntryGlassCard extends StatelessWidget {
  final Widget child;

  const EntryGlassCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: child,
        ),
      ),
    );
  }
}
