import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/enums.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/widgets/app_search_bar.dart';
import '../../domain/defensivo_model.dart';
import '../providers/defensivos_search_providers.dart';
import '../screens/add_edit_defensivo_screen.dart';

class DefensivoPickerSheet extends ConsumerStatefulWidget {
  final String? selectedDefensivoId;

  const DefensivoPickerSheet({super.key, this.selectedDefensivoId});

  @override
  ConsumerState<DefensivoPickerSheet> createState() =>
      _DefensivoPickerSheetState();
}

class _DefensivoPickerSheetState extends ConsumerState<DefensivoPickerSheet> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defensivosAsync = ref.watch(filteredSortedDefensivosProvider);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
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
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                context.l10n.selectDefensivoTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              AppSearchBar<DefensivoSortOption>(
                controller: _searchController,
                hintText: context.l10n.searchDefensivosHint,
                onChanged: (value) {
                  ref
                      .read(defensivoSearchQueryProvider.notifier)
                      .setQuery(value);
                },
                onSortSelected: (option) {
                  ref
                      .read(defensivoSortOptionNotifierProvider.notifier)
                      .setSortOption(option);
                },
                sortOptions: [
                  PopupMenuItem(
                    value: DefensivoSortOption.nameAZ,
                    child: Text(context.l10n.sortNameAZ),
                  ),
                  PopupMenuItem(
                    value: DefensivoSortOption.nameZA,
                    child: Text(context.l10n.sortNameZA),
                  ),
                  PopupMenuItem(
                    value: DefensivoSortOption.dateAdded,
                    child: Text(context.l10n.sortDateAdded),
                  ),
                ],
              ),
              Expanded(
                child: defensivosAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                  error: (e, _) => Center(
                    child: Text(
                      context.l10n.errorGeneric('$e'),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  data: (defensivos) {
                    return ListView.builder(
                      padding:
                          EdgeInsets.fromLTRB(16, 0, 16, 16 + bottomInset),
                      itemCount: defensivos.length + 1,
                      itemBuilder: (context, index) {
                        if (index == defensivos.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: FilledButton.icon(
                              onPressed: () async {
                                final saved =
                                    await Navigator.push<DefensivoModel>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const AddEditDefensivoScreen(),
                                  ),
                                );
                                if (saved != null && context.mounted) {
                                  Navigator.pop(context, saved);
                                }
                              },
                              icon: const Icon(Icons.add),
                              label: Text(context.l10n.newDefensivo),
                              style: FilledButton.styleFrom(
                                backgroundColor:
                                    Colors.white.withValues(alpha: 0.1),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          );
                        }

                        if (defensivos.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Text(
                              context.l10n.noDefensivosFound,
                              style: const TextStyle(color: Colors.white70),
                            ),
                          );
                        }

                        final defensivo = defensivos[index];
                        final isSelected =
                            defensivo.id == widget.selectedDefensivoId;

                        return _DefensivoListTile(
                          defensivo: defensivo,
                          isSelected: isSelected,
                          onTap: () => Navigator.pop(context, defensivo),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DefensivoListTile extends StatelessWidget {
  final DefensivoModel defensivo;
  final bool isSelected;
  final VoidCallback onTap;

  const _DefensivoListTile({
    required this.defensivo,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final categoryLabel =
        defensivo.displayCategoryLabel((c) => c.label(context.l10n));

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)
                : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  image: defensivo.imagePath != null
                      ? DecorationImage(
                          image: FileImage(File(defensivo.imagePath!)),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: defensivo.imagePath == null
                    ? const Icon(Icons.science_outlined, color: Colors.white70)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      defensivo.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (categoryLabel != null)
                      Text(
                        categoryLabel,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
