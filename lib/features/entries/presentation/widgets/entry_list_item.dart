import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/enums.dart';
import '../../domain/entry_model.dart';

class EntryListItem extends StatelessWidget {
  final EntryModel entry;
  final VoidCallback? onDelete;

  const EntryListItem({super.key, required this.entry, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Entry type indicator
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child:
                  Text(entry.type.emoji, style: const TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.type.label,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        DateFormat('dd/MM/yy HH:mm').format(entry.date),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  if (entry.note != null && entry.note!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(entry.note!),
                  ],
                  if (entry.photoPath != null) ...[
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(entry.photoPath!),
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (onDelete != null && entry.type != EntryType.history)
              IconButton(
                icon: const Icon(Icons.delete_outline),
                iconSize: 20,
                onPressed: onDelete,
              ),
          ],
        ),
      ),
    );
  }
}
