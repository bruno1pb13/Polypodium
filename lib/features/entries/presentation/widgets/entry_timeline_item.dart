import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/enums.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/widgets/emoji_text.dart';
import '../../../../core/widgets/fullscreen_image_viewer.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../../domain/entry_details.dart';
import '../../domain/entry_model.dart';
import '../../../../core/theme/glass_colors.dart';

class EntryTimelineItem extends ConsumerWidget {
  final EntryModel entry;
  final VoidCallback? onDelete;
  final bool isLast;

  const EntryTimelineItem({
    super.key,
    required this.entry,
    this.onDelete,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transparencyEnabled = ref.watch(transparencyEnabledNotifierProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Timeline indicator column
            SliverTimelineIndicator(
              type: entry.type,
              isLast: isLast,
            ),
            const SizedBox(width: 12),
            // Entry content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: transparencyEnabled
                        ? ImageFilter.blur(sigmaX: 10, sigmaY: 10)
                        : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: transparencyEnabled
                            ? context.glass.scrim(0.25)
                            : Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: transparencyEnabled
                              ? context.glass.tint(0.1)
                              : Colors.transparent,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Wraps the date below the type at large text
                          // sizes instead of overflowing.
                          SizedBox(
                            width: double.infinity,
                            child: Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              children: [
                                Text(
                                  entry.type.label(context.l10n),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: transparencyEnabled
                                        ? context.glass.fg
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  DateFormat.yMd(context.l10n.localeName)
                                      .add_Hm()
                                      .format(entry.date),
                                  style: TextStyle(
                                    color: transparencyEnabled
                                        ? context.glass.fgMuted
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant
                                            .withValues(alpha: 0.7),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _EntryDataBadge(
                            entry: entry,
                            transparent: transparencyEnabled,
                          ),
                          if (entry.note != null && entry.note!.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              entry.note!,
                              style: TextStyle(
                                color: transparencyEnabled
                                    ? context.glass.fg
                                    : Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                fontSize: 14,
                                height: 1.4,
                              ),
                            ),
                          ],
                          if (entry.photoPath != null) ...[
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Semantics(
                                container: true,
                                button: true,
                                image: true,
                                label: context.l10n.entryPhotoLabel(
                                    DateFormat.yMd(context.l10n.localeName)
                                        .format(entry.date)),
                                child: GestureDetector(
                                  onTap: () => showFullscreenImageViewer(
                                      context, entry.photoPath!),
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: 320,
                                      maxHeight: 220,
                                    ),
                                    child: AspectRatio(
                                      aspectRatio: 4 / 3,
                                      child: Image.file(
                                        File(entry.photoPath!),
                                        fit: BoxFit.cover,
                                        excludeFromSemantics: true,
                                        errorBuilder: (_, __, ___) =>
                                            const SizedBox.shrink(),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                          if (onDelete != null &&
                              entry.type != EntryType.history) ...[
                            const SizedBox(height: 4),
                            Align(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                icon: Icon(
                                  Icons.delete_outline,
                                  color: transparencyEnabled
                                      ? context.glass.fgSubtle
                                      : Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant
                                          .withValues(alpha: 0.6),
                                  size: 20,
                                ),
                                tooltip: context.l10n.delete,
                                onPressed: onDelete,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

typedef _Summary = (String emoji, String text);

/// Shows the structured data saved with an entry as a compact pill row.
class _EntryDataBadge extends StatelessWidget {
  final EntryModel entry;
  final bool transparent;

  const _EntryDataBadge({required this.entry, required this.transparent});

  @override
  Widget build(BuildContext context) {
    final summary = _summary(context.l10n);
    if (summary == null) return const SizedBox.shrink();
    final (emoji, text) = summary;

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: transparent
              ? context.glass.tint(0.12)
              : Theme.of(context)
                  .colorScheme
                  .secondaryContainer
                  .withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: EmojiText(
          emoji,
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: transparent
                ? context.glass.fgAlpha(0.85)
                : Theme.of(context).colorScheme.onSecondaryContainer,
          ),
        ),
      ),
    );
  }

  _Summary? _summary(AppLocalizations l10n) {
    final nv = entry.numericValue;
    final details = entry.details;

    return switch (entry.type) {
      EntryType.height when nv != null => ('📏', '${_fmt(nv)} cm'),
      EntryType.chlorosis when nv != null => nv.toInt() == 0
          ? ('💚', l10n.chlorosisCured)
          : ('🟡', _severityLabel(l10n, nv.toInt())),
      EntryType.pest => _pestSummary(l10n, details as PestDetails?, nv),
      EntryType.irrigation when nv != null =>
        ('💧', _irrigationLabel(l10n, nv.toInt())),
      EntryType.fertilizer =>
        _fertilizerSummary(l10n, details as FertilizerDetails?),
      EntryType.pruning when details is PruningDetails =>
        ('✂️', _pruningLabel(l10n, details.reason)),
      EntryType.pesticide =>
        _pesticideSummary(l10n, details as PesticideDetails?, entry.date),
      EntryType.observation when nv != null =>
        (
          _healthEmoji(nv.toInt()),
          '${l10n.healthSummary(nv.toInt())} — ${_healthLabel(l10n, nv.toInt())}',
        ),
      _ => null,
    };
  }

  _Summary? _pestSummary(
      AppLocalizations l10n, PestDetails? details, double? nv) {
    if (nv != null && nv.toInt() == 0) return ('✅', l10n.pestEradicated);
    final pestType = details?.pestType;
    final parts = [
      if (pestType != null && pestType.isNotEmpty) pestType,
      if (nv != null) _severityLabel(l10n, nv.toInt()),
    ];
    if (parts.isEmpty) return null;
    return ('🐛', parts.join(' · '));
  }

  _Summary? _fertilizerSummary(
      AppLocalizations l10n, FertilizerDetails? details) {
    final products = details?.products ?? const [];
    if (products.isEmpty) return null;
    if (products.length == 1) {
      final p = products.single;
      final dosePart = p.dose != null ? ' · ${_fmt(p.dose!)} ml' : '';
      return ('🌱', '${p.name}$dosePart');
    }
    return ('🌱', l10n.productsCount(products.length));
  }

  _Summary? _pesticideSummary(
      AppLocalizations l10n, PesticideDetails? details, DateTime date) {
    if (details == null) return null;
    final products = details.products;
    final recurrenceDays = details.recurrenceDays;

    final productsPart = switch (products) {
      [] => null,
      [final p] => p.name,
      _ => l10n.productsCount(products.length),
    };

    // Only worth showing while the next application is still ahead; on older
    // entries that date has long passed.
    final nextDate =
        recurrenceDays != null ? date.add(Duration(days: recurrenceDays)) : null;
    final nextPart = nextDate != null && nextDate.isAfter(DateTime.now())
        ? l10n.nextPesticideApplication(
            DateFormat.yMd(l10n.localeName).format(nextDate))
        : null;

    final parts = [
      if (productsPart != null && productsPart.isNotEmpty) productsPart,
      if (nextPart != null) nextPart,
    ];
    if (parts.isEmpty) return null;
    return ('🧪', parts.join(' · '));
  }

  String _fmt(double v) =>
      v == v.truncateToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

  String _irrigationLabel(AppLocalizations l10n, int v) => switch (v) {
        1 => l10n.irrigationScarce,
        2 => l10n.irrigationModerate,
        3 => l10n.irrigationIntense,
        _ => '$v',
      };

  String _severityLabel(AppLocalizations l10n, int v) => switch (v) {
        1 => l10n.severityMild,
        2 => l10n.severityModerate,
        3 => l10n.severitySevere,
        _ => '$v',
      };

  String _pruningLabel(AppLocalizations l10n, String? key) => switch (key) {
        'formacao' => l10n.pruningFormation,
        'limpeza' => l10n.pruningCleaning,
        'rejuvenescimento' => l10n.pruningRejuvenation,
        'colheita' => l10n.pruningHarvest,
        _ => key ?? '',
      };

  String _healthEmoji(int score) => switch (score) {
        1 => '🔴',
        2 => '🟠',
        3 => '🟡',
        4 => '🟢',
        5 => '💚',
        _ => '',
      };

  String _healthLabel(AppLocalizations l10n, int score) => switch (score) {
        1 => l10n.healthCritical,
        2 => l10n.healthBad,
        3 => l10n.healthRegular,
        4 => l10n.healthGood,
        5 => l10n.healthExcellent,
        _ => '',
      };
}

class SliverTimelineIndicator extends ConsumerWidget {
  final EntryType type;
  final bool isLast;

  const SliverTimelineIndicator({
    super.key,
    required this.type,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transparencyEnabled = ref.watch(transparencyEnabledNotifierProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Positioned(
          top: 0,
          bottom: isLast ? null : 0,
          height: isLast ? 20 : null,
          child: Container(
            width: 2,
            color: transparencyEnabled
                ? context.glass.outline
                : colorScheme.outlineVariant,
          ),
        ),
        Column(
          children: [
            const SizedBox(height: 20),
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: transparencyEnabled
                    ? context.glass.tint(0.4)
                    : colorScheme.surfaceContainer,
                shape: BoxShape.circle,
                border: Border.all(
                  color: transparencyEnabled
                      ? context.glass.fg
                      : colorScheme.outlineVariant,
                ),
              ),
              alignment: Alignment.center,
            ),
          ],
        ),
      ],
    );
  }
}
