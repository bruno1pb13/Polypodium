import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/enums.dart';
import '../../domain/entry_model.dart';

class EntryTimelineItem extends StatelessWidget {
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
  Widget build(BuildContext context) {
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
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                entry.type.label,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                DateFormat('dd/MM/yy HH:mm').format(entry.date),
                                style: const TextStyle(
                                  color: Colors.white60,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          if (entry.note != null && entry.note!.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              entry.note!,
                              style: const TextStyle(
                                color: Colors.white,
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
                          if (onDelete != null && entry.type != EntryType.history) ...[
                            const SizedBox(height: 4),
                            Align(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    color: Colors.white60, size: 20),
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

class SliverTimelineIndicator extends StatelessWidget {
  final EntryType type;
  final bool isLast;

  const SliverTimelineIndicator({
    super.key,
    required this.type,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white24),
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
              color: Colors.white24,
            ),
          )
        else
          const Expanded(child: SizedBox()),
      ],
    );
  }
}
