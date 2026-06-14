import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/enums.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../../domain/entry_model.dart';

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
                            ? Colors.black.withValues(alpha: 0.25)
                            : Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: transparencyEnabled
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.transparent,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                entry.type.label,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: transparencyEnabled
                                      ? Colors.white
                                      : Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                  fontSize: 16,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                DateFormat('dd/MM/yy HH:mm').format(entry.date),
                                style: TextStyle(
                                  color: transparencyEnabled
                                      ? Colors.white60
                                      : Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant
                                          .withValues(alpha: 0.7),
                                  fontSize: 12,
                                ),
                              ),
                            ],
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
                                    ? Colors.white
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
                              child: Image.file(
                                File(entry.photoPath!),
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const SizedBox.shrink(),
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
                                      ? Colors.white60
                                      : Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant
                                          .withValues(alpha: 0.6),
                                  size: 20,
                                ),
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

/// Shows the structured data saved with an entry as a compact pill row.
class _EntryDataBadge extends StatelessWidget {
  final EntryModel entry;
  final bool transparent;

  const _EntryDataBadge({required this.entry, required this.transparent});

  @override
  Widget build(BuildContext context) {
    final text = _summaryText();
    if (text == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: transparent
              ? Colors.white.withValues(alpha: 0.12)
              : Theme.of(context)
                  .colorScheme
                  .secondaryContainer
                  .withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: transparent
                ? Colors.white.withValues(alpha: 0.85)
                : Theme.of(context).colorScheme.onSecondaryContainer,
          ),
        ),
      ),
    );
  }

  String? _summaryText() {
    final nv = entry.numericValue;
    final extra = entry.extraData != null
        ? (jsonDecode(entry.extraData!) as Map<String, dynamic>)
        : null;

    return switch (entry.type) {
      EntryType.height when nv != null => '📏 ${_fmt(nv)} cm',
      EntryType.chlorosis when nv != null => nv.toInt() == 0
          ? '💚 Curada'
          : '🟡 ${_severityLabel(nv.toInt())}',
      EntryType.pest => _pestSummary(extra, nv),
      EntryType.irrigation when nv != null => '💧 ${_irrigationLabel(nv.toInt())}',
      EntryType.fertilizer => _fertilizerSummary(extra),
      EntryType.pruning when extra != null =>
        '✂️ ${_pruningLabel(extra['reason'] as String?)}',
      EntryType.observation when nv != null =>
        '${_healthEmoji(nv.toInt())} Saúde ${nv.toInt()}/5 — ${_healthLabel(nv.toInt())}',
      _ => null,
    };
  }

  String? _pestSummary(Map<String, dynamic>? extra, double? nv) {
    if (nv != null && nv.toInt() == 0) return '✅ Erradicada';
    final pestType = extra?['pestType'] as String?;
    final parts = [
      if (pestType != null && pestType.isNotEmpty) pestType,
      if (nv != null) _severityLabel(nv.toInt()),
    ];
    if (parts.isEmpty) return null;
    return '🐛 ${parts.join(' · ')}';
  }

  String? _fertilizerSummary(Map<String, dynamic>? extra) {
    if (extra == null) return null;
    // New format: {"products": [{"name": "...", "dose": X}, ...]}
    final products = extra['products'] as List<dynamic>?;
    if (products != null && products.isNotEmpty) {
      if (products.length == 1) {
        final p = products[0] as Map<String, dynamic>;
        final name = p['name'] as String? ?? '';
        final dose = p['dose'];
        final dosePart =
            dose != null ? ' · ${_fmt((dose as num).toDouble())} ml' : '';
        return '🌱 $name$dosePart';
      }
      return '🌱 ${products.length} produtos';
    }
    return null;
  }

  String _fmt(double v) =>
      v == v.truncateToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

  String _irrigationLabel(int v) => switch (v) {
        1 => 'Escassa',
        2 => 'Moderada',
        3 => 'Intensa',
        _ => '$v',
      };

  String _severityLabel(int v) => switch (v) {
        1 => 'Leve',
        2 => 'Moderada',
        3 => 'Severa',
        _ => '$v',
      };

  String _pruningLabel(String? key) => switch (key) {
        'formacao' => 'Formação',
        'limpeza' => 'Limpeza',
        'rejuvenescimento' => 'Rejuvenescimento',
        'colheita' => 'Colheita',
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

  String _healthLabel(int score) => switch (score) {
        1 => 'Crítica',
        2 => 'Ruim',
        3 => 'Regular',
        4 => 'Boa',
        5 => 'Ótima',
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
                ? Colors.white24
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
                    ? Colors.white.withValues(alpha: 0.4)
                    : colorScheme.surfaceContainer,
                shape: BoxShape.circle,
                border: Border.all(
                  color: transparencyEnabled
                      ? Colors.white
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
