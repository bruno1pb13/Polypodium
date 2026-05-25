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

    return Column(
      children: [
        const SizedBox(height: 12),
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: transparencyEnabled
                ? Colors.white.withValues(alpha: 0.15)
                : colorScheme.surfaceContainer,
            shape: BoxShape.circle,
            border: Border.all(
              color: transparencyEnabled ? Colors.white24 : colorScheme.outlineVariant,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            type.emoji,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        if (!isLast)
          Expanded(
            child: Container(
              width: 2,
              color: transparencyEnabled ? Colors.white24 : colorScheme.outlineVariant,
            ),
          )
        else
          const Expanded(child: SizedBox()),
      ],
    );
  }
}
