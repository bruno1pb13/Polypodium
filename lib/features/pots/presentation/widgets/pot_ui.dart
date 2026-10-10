import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/enums.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/glass_colors.dart';
import '../../domain/pot_model.dart';

/// Size and material of [pot] for display, e.g. "25 cm · Barro"; null when
/// neither is known.
String? potSpecs(AppLocalizations l10n, PotModel pot) {
  final diameter = pot.diameterCm;
  final parts = [
    if (diameter != null) '${formatPotDiameter(diameter)} cm',
    if (pot.material != null) pot.material!.label(l10n),
  ];
  return parts.isEmpty ? null : parts.join(' · ');
}

String formatPotDiameter(double v) =>
    v == v.truncateToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

/// Parses a typed diameter ("25", "12,5"); null when blank, invalid or not
/// positive.
double? parsePotDiameter(String text) {
  final v = double.tryParse(text.trim().replaceAll(',', '.'));
  return v != null && v > 0 ? v : null;
}

/// Scaffold with the app's glass background, shared by the pot screens.
class PotScreenScaffold extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final Widget body;
  final Widget? floatingActionButton;

  const PotScreenScaffold({
    super.key,
    required this.title,
    this.actions,
    required this.body,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: context.glass.fg),
        title: Text(
          title,
          style: TextStyle(
            color: context.glass.fg,
            fontWeight: FontWeight.w600,
            shadows: [
              Shadow(
                color: context.glass.shadow(Colors.black45),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        actions: actions,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
              excludeFromSemantics: true,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    context.glass.scrim(0.5),
                    Colors.transparent,
                    context.glass.scrim(0.3),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(child: body),
        ],
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}

class PotGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const PotGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: context.glass.scrim(0.3),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: context.glass.tint(0.1)),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Bottom sheet frame (handle, title) in the style of the soil picker.
class PotSheetFrame extends StatelessWidget {
  final String title;
  final Widget child;
  final double heightFactor;

  const PotSheetFrame({
    super.key,
    required this.title,
    required this.child,
    this.heightFactor = 0.8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * heightFactor,
      decoration: BoxDecoration(
        color: context.glass.sheet,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: context.glass.tint(0.1)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.glass.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: context.glass.fg,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}

/// Selectable row of a picker sheet.
class PotPickerTile extends StatelessWidget {
  final Widget leading;
  final String title;
  final String? subtitle;

  /// Shown right after the title (which is ellipsized first).
  final Widget? titleSuffix;
  final bool selected;
  final Widget? trailing;
  final VoidCallback? onTap;

  const PotPickerTile({
    super.key,
    required this.leading,
    required this.title,
    this.subtitle,
    this.titleSuffix,
    this.selected = false,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: selected
                ? primary.withValues(alpha: 0.2)
                : context.glass.tint(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? primary : context.glass.tint(0.1),
            ),
          ),
          child: Row(
            children: [
              SizedBox(width: 40, height: 40, child: Center(child: leading)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: context.glass.fg,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        if (titleSuffix != null) ...[
                          const SizedBox(width: 6),
                          titleSuffix!,
                        ],
                      ],
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty)
                      Text(
                        subtitle!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: context.glass.fgMuted,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
              if (selected && trailing == null)
                Icon(Icons.check_circle, color: primary),
            ],
          ),
        ),
      ),
    );
  }
}

/// The kind emoji in a rounded square, as the pots' leading icon.
class PotKindBadge extends StatelessWidget {
  final PotKind kind;
  final double size;

  const PotKindBadge({super.key, required this.kind, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: context.glass.tint(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExcludeSemantics(
        child: Text(kind.emoji, style: TextStyle(fontSize: size * 0.45)),
      ),
    );
  }
}

/// Input theme of the glass forms (same as the location form's).
ThemeData potFormTheme(BuildContext context) {
  final base = Theme.of(context);
  final primary = base.colorScheme.primary;
  OutlineInputBorder border([Color? color]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color ?? context.glass.outline),
      );

  return base.copyWith(
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: context.glass.tint(0.05),
      labelStyle: TextStyle(color: context.glass.fgMuted),
      floatingLabelStyle: TextStyle(color: primary),
      hintStyle: TextStyle(color: context.glass.fgAlpha(0.4)),
      helperStyle: TextStyle(color: context.glass.fgSubtle),
      prefixIconColor: context.glass.fgMuted,
      suffixIconColor: context.glass.fgMuted,
      iconColor: context.glass.fgMuted,
      border: border(),
      enabledBorder: border(),
      focusedBorder: border(primary),
      errorBorder: border(base.colorScheme.error),
      focusedErrorBorder: border(base.colorScheme.error),
      errorStyle: TextStyle(color: base.colorScheme.error),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: primary,
      selectionColor: primary.withValues(alpha: 0.4),
      selectionHandleColor: primary,
    ),
  );
}

/// Row of choice chips in the style of the repotting form's material chips.
class PotChoiceChips<T> extends StatelessWidget {
  final List<T> values;
  final T? selected;
  final String Function(T) label;
  final ValueChanged<T?> onChanged;

  /// Whether tapping the selected chip clears the choice.
  final bool allowClear;

  const PotChoiceChips({
    super.key,
    required this.values,
    required this.selected,
    required this.label,
    required this.onChanged,
    this.allowClear = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final v in values)
          ChoiceChip(
            label: Text(label(v)),
            selected: selected == v,
            onSelected: (_) =>
                onChanged(selected == v ? (allowClear ? null : v) : v),
            backgroundColor: context.glass.scrim(0.2),
            selectedColor: colors.primary,
            showCheckmark: false,
            labelStyle: TextStyle(
              color: selected == v ? colors.onPrimary : context.glass.fgMuted,
              fontSize: 13,
              fontWeight: selected == v ? FontWeight.bold : FontWeight.normal,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: selected == v
                    ? context.glass.tint(0.3)
                    : context.glass.tint(0.12),
              ),
            ),
          ),
      ],
    );
  }
}
