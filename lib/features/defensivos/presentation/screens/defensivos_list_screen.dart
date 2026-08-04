import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/enums.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/widgets/app_search_bar.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../../domain/defensivo_model.dart';
import '../providers/defensivos_providers.dart';
import '../providers/defensivos_search_providers.dart';
import 'add_edit_defensivo_screen.dart';

class DefensivosListScreen extends ConsumerStatefulWidget {
  const DefensivosListScreen({super.key});

  @override
  ConsumerState<DefensivosListScreen> createState() =>
      _DefensivosListScreenState();
}

class _DefensivosListScreenState extends ConsumerState<DefensivosListScreen> {
  final _searchController = TextEditingController();

  Future<void> _refresh() async {
    ref.invalidate(defensivosNotifierProvider);
    try {
      await ref.read(filteredSortedDefensivosProvider.future);
    } catch (_) {}
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defensivosAsync = ref.watch(filteredSortedDefensivosProvider);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          context.l10n.navDefensivos,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.5),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.3),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
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
                  child: RefreshIndicator(
                    onRefresh: _refresh,
                    color: Colors.white,
                    backgroundColor: Colors.black54,
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
                        if (defensivos.isEmpty) {
                          return LayoutBuilder(
                            builder: (_, constraints) => SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: SizedBox(
                                height: constraints.maxHeight,
                                child: _searchController.text.isNotEmpty
                                    ? Center(
                                        child: Text(
                                            context.l10n.noDefensivosFound,
                                            style: const TextStyle(
                                                color: Colors.white)))
                                    : const _EmptyState(),
                              ),
                            ),
                          );
                        }
                        return ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(top: 8, bottom: 80),
                          itemCount: defensivos.length,
                          itemBuilder: (ctx, i) => _DefensivoListItem(
                            defensivo: defensivos[i],
                            onEdit: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddEditDefensivoScreen(
                                    defensivo: defensivos[i]),
                              ),
                            ),
                            onDelete: () =>
                                _confirmDelete(context, ref, defensivos[i].id),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddEditDefensivoScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    String id,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.l10n.deleteDefensivoTitle),
        content: Text(ctx.l10n.deleteDefensivoBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(ctx.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(ctx.l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(defensivosNotifierProvider.notifier).delete(id);
    }
  }
}

class _DefensivoListItem extends ConsumerWidget {
  final DefensivoModel defensivo;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _DefensivoListItem({
    required this.defensivo,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transparencyEnabled = ref.watch(transparencyEnabledNotifierProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final categoryLabel = defensivo.displayCategoryLabel(
        (c) => c.label(context.l10n));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: transparencyEnabled
              ? ImageFilter.blur(sigmaX: 10, sigmaY: 10)
              : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
          child: Container(
            decoration: BoxDecoration(
              color: transparencyEnabled
                  ? Colors.black.withValues(alpha: 0.35)
                  : colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: transparencyEnabled
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.transparent,
              ),
            ),
            child: InkWell(
              onTap: onEdit,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: transparencyEnabled
                            ? Colors.white.withValues(alpha: 0.1)
                            : colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                        image: defensivo.imagePath != null
                            ? DecorationImage(
                                image: defensivo.imagePath!
                                        .startsWith('assets/')
                                    ? AssetImage(defensivo.imagePath!)
                                        as ImageProvider
                                    : FileImage(File(defensivo.imagePath!)),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: defensivo.imagePath == null
                          ? Icon(
                              Icons.science_outlined,
                              color: transparencyEnabled
                                  ? Colors.white
                                  : colorScheme.primary,
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            defensivo.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: transparencyEnabled
                                  ? Colors.white
                                  : colorScheme.onSurfaceVariant,
                              shadows: transparencyEnabled
                                  ? [
                                      const Shadow(
                                        color: Colors.black26,
                                        offset: Offset(0, 1),
                                        blurRadius: 2,
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                          if (categoryLabel != null &&
                              categoryLabel.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              categoryLabel,
                              style: TextStyle(
                                fontSize: 13,
                                color: transparencyEnabled
                                    ? Colors.white70
                                    : colorScheme.onSurfaceVariant
                                        .withValues(alpha: 0.7),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      color: transparencyEnabled
                          ? Colors.white70
                          : colorScheme.onSurfaceVariant,
                      onPressed: onEdit,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      color: transparencyEnabled
                          ? Colors.white70
                          : colorScheme.onSurfaceVariant,
                      onPressed: onDelete,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.science_outlined,
            size: 64,
            color: Colors.white.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.noDefensivosRegistered,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.tapToAddDefensivo,
            style: const TextStyle(fontSize: 13, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
