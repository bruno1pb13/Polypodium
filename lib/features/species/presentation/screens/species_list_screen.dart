import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/enums.dart';
import '../../../../core/widgets/app_search_bar.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../../data/external_species_repository.dart';
import '../../domain/species_model.dart';
import '../providers/species_providers.dart';
import '../providers/species_search_providers.dart';
import 'add_species_screen.dart';

class SpeciesListScreen extends ConsumerStatefulWidget {
  const SpeciesListScreen({super.key});

  @override
  ConsumerState<SpeciesListScreen> createState() => _SpeciesListScreenState();
}

class _SpeciesListScreenState extends ConsumerState<SpeciesListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final speciesAsync = ref.watch(filteredSortedSpeciesProvider);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Espécies',
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
                AppSearchBar<SpeciesSortOption>(
                  controller: _searchController,
                  hintText: 'Buscar espécies...',
                  onChanged: (value) {
                    ref.read(speciesSearchQueryProvider.notifier).setQuery(value);
                  },
                  onSortSelected: (option) {
                    ref
                        .read(speciesSortOptionNotifierProvider.notifier)
                        .setSortOption(option);
                  },
                  sortOptions: const [
                    PopupMenuItem(
                      value: SpeciesSortOption.popularAZ,
                      child: Text('Nome Popular (A-Z)'),
                    ),
                    PopupMenuItem(
                      value: SpeciesSortOption.popularZA,
                      child: Text('Nome Popular (Z-A)'),
                    ),
                    PopupMenuItem(
                      value: SpeciesSortOption.scientificAZ,
                      child: Text('Nome Científico (A-Z)'),
                    ),
                    PopupMenuItem(
                      value: SpeciesSortOption.scientificZA,
                      child: Text('Nome Científico (Z-A)'),
                    ),
                    PopupMenuItem(
                      value: SpeciesSortOption.dateAdded,
                      child: Text('Data de Adição'),
                    ),
                  ],
                ),
                _InfoBanner(),
                Expanded(
                  child: speciesAsync.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                    error: (e, _) => Center(
                      child: Text(
                        'Erro: $e',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    data: (species) {
                      if (species.isEmpty) {
                        return _searchController.text.isNotEmpty
                            ? const Center(
                                child: Text('Nenhuma espécie encontrada',
                                    style: TextStyle(color: Colors.white)))
                            : const _EmptyState();
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.only(top: 8, bottom: 80),
                        itemCount: species.length,
                        itemBuilder: (ctx, i) => _SpeciesListItem(
                          species: species[i],
                          onEdit: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  AddSpeciesScreen(species: species[i]),
                            ),
                          ),
                          onDelete: () =>
                              _confirmDelete(context, ref, species[i].id),
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
          MaterialPageRoute(builder: (_) => const AddSpeciesScreen()),
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
        title: const Text('Deletar espécie?'),
        content:
            const Text('Plantas vinculadas a esta espécie não serão afetadas.'),
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
      await ref.read(speciesNotifierProvider.notifier).delete(id);
    }
  }
}

class _InfoBanner extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transparencyEnabled = ref.watch(transparencyEnabledNotifierProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
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
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: transparencyEnabled
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.transparent,
              ),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 18,
                      color: transparencyEnabled
                          ? Colors.white
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Usando dados oficiais da Flora e Funga do Brasil (JBRJ).',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: transparencyEnabled
                              ? Colors.white
                              : Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                FutureBuilder<int>(
                  future: ref
                      .read(externalSpeciesRepositoryProvider.notifier)
                      .getSpeciesCount(),
                  builder: (context, snapshot) {
                    return Text(
                      'Total de espécies disponíveis: ${snapshot.data ?? "..."}',
                      style: TextStyle(
                        fontSize: 12,
                        color: transparencyEnabled
                            ? Colors.white70
                            : Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant
                                .withValues(alpha: 0.7),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 4),
                FutureBuilder<String>(
                  future: ref
                      .read(externalSpeciesRepositoryProvider.notifier)
                      .getLastUpdateDate(),
                  builder: (context, snapshot) {
                    return Text(
                      'Última atualização: ${snapshot.data ?? "..."}',
                      style: TextStyle(
                        fontSize: 12,
                        color: transparencyEnabled
                            ? Colors.white70
                            : Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant
                                .withValues(alpha: 0.7),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => _handleUpdate(context, ref),
                  icon: const Icon(Icons.download, size: 16),
                  label: const Text('Baixar versão atualizada (JBRJ)'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: transparencyEnabled
                        ? Colors.white
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                    side: BorderSide(
                      color: transparencyEnabled
                          ? Colors.white.withValues(alpha: 0.4)
                          : Theme.of(context).colorScheme.outline,
                    ),
                    visualDensity: VisualDensity.compact,
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleUpdate(BuildContext context, WidgetRef ref) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    scaffoldMessenger.showSnackBar(
      const SnackBar(content: Text('Iniciando download do dataset oficial...')),
    );

    try {
      await ref
          .read(externalSpeciesRepositoryProvider.notifier)
          .downloadAndUpdate();
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Dataset atualizado com sucesso!')),
      );
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Erro ao atualizar: $e')),
      );
    }
  }
}

class _SpeciesListItem extends ConsumerWidget {
  final SpeciesModel species;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SpeciesListItem({
    required this.species,
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
                        Icons.eco_outlined,
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
                            species.popularName,
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
                          const SizedBox(height: 2),
                          Text(
                            species.scientificName,
                            style: TextStyle(
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                              color: transparencyEnabled
                                  ? Colors.white70
                                  : colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.7),
                            ),
                          ),
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
            Icons.eco_outlined,
            size: 64,
            color: Colors.white.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          const Text(
            'Nenhuma espécie cadastrada',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            'Toque em + para adicionar uma nova espécie.',
            style: TextStyle(fontSize: 13, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
