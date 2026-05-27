import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/enums.dart';
import '../../../../core/widgets/app_search_bar.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../../domain/soil_model.dart';
import '../providers/soils_providers.dart';
import '../providers/soils_search_providers.dart';
import 'add_edit_soil_screen.dart';

class SoilsListScreen extends ConsumerStatefulWidget {
  const SoilsListScreen({super.key});

  @override
  ConsumerState<SoilsListScreen> createState() => _SoilsListScreenState();
}

class _SoilsListScreenState extends ConsumerState<SoilsListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final soilsAsync = ref.watch(filteredSortedSoilsProvider);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Solos',
          style: TextStyle(
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
                AppSearchBar<SoilSortOption>(
                  controller: _searchController,
                  hintText: 'Buscar solos...',
                  onChanged: (value) {
                    ref.read(soilSearchQueryProvider.notifier).setQuery(value);
                  },
                  onSortSelected: (option) {
                    ref
                        .read(soilSortOptionNotifierProvider.notifier)
                        .setSortOption(option);
                  },
                  sortOptions: const [
                    PopupMenuItem(
                      value: SoilSortOption.nameAZ,
                      child: Text('Nome (A-Z)'),
                    ),
                    PopupMenuItem(
                      value: SoilSortOption.nameZA,
                      child: Text('Nome (Z-A)'),
                    ),
                    PopupMenuItem(
                      value: SoilSortOption.dateAdded,
                      child: Text('Data de Adição'),
                    ),
                  ],
                ),
                Expanded(
                  child: soilsAsync.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                    error: (e, _) => Center(
                      child: Text(
                        'Erro: $e',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    data: (soils) {
                      if (soils.isEmpty) {
                        return _searchController.text.isNotEmpty
                            ? const Center(
                                child: Text('Nenhum solo encontrado',
                                    style: TextStyle(color: Colors.white)))
                            : const _EmptyState();
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.only(top: 8, bottom: 80),
                        itemCount: soils.length,
                        itemBuilder: (ctx, i) => _SoilListItem(
                          soil: soils[i],
                          onEdit: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddEditSoilScreen(soil: soils[i]),
                            ),
                          ),
                          onDelete: () => _confirmDelete(context, ref, soils[i].id),
                        ),
                      );
                    },
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
          MaterialPageRoute(builder: (_) => const AddEditSoilScreen()),
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
        title: const Text('Deletar solo?'),
        content: const Text(
            'Plantas e espécies vinculadas a este solo não serão deletadas, mas a referência ao solo pode ser perdida.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Deletar'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(soilsNotifierProvider.notifier).delete(id);
    }
  }
}

class _SoilListItem extends ConsumerWidget {
  final SoilModel soil;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SoilListItem({
    required this.soil,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transparencyEnabled = ref.watch(transparencyEnabledNotifierProvider);
    final colorScheme = Theme.of(context).colorScheme;

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
                      ),
                      child: Icon(
                        Icons.terrain_outlined,
                        color: transparencyEnabled
                            ? Colors.white
                            : colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            soil.name,
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
                          if (soil.composition != null &&
                              soil.composition!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              soil.composition!,
                              style: TextStyle(
                                fontSize: 13,
                                color: transparencyEnabled
                                    ? Colors.white70
                                    : colorScheme.onSurfaceVariant
                                        .withValues(alpha: 0.7),
                              ),
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
            Icons.terrain_outlined,
            size: 64,
            color: Colors.white.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          const Text(
            'Nenhum tipo de solo cadastrado',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            'Toque em + para adicionar um tipo de solo.',
            style: TextStyle(fontSize: 13, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
