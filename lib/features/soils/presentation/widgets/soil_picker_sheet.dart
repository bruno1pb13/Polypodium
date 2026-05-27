import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/enums.dart';
import '../../../../core/widgets/app_search_bar.dart';
import '../../domain/soil_model.dart';
import '../providers/soils_search_providers.dart';
import '../screens/add_edit_soil_screen.dart';

class SoilPickerSheet extends ConsumerStatefulWidget {
  final String? selectedSoilId;

  const SoilPickerSheet({super.key, this.selectedSoilId});

  @override
  ConsumerState<SoilPickerSheet> createState() => _SoilPickerSheetState();
}

class _SoilPickerSheetState extends ConsumerState<SoilPickerSheet> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final soilsAsync = ref.watch(filteredSortedSoilsProvider);
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
              const Text(
                'Selecionar Solo',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
                      return const Center(
                        child: Text(
                          'Nenhum solo encontrado',
                          style: TextStyle(color: Colors.white70),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottomInset),
                      itemCount: soils.length + 1,
                      itemBuilder: (context, index) {
                        if (index == soils.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: FilledButton.icon(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AddEditSoilScreen(),
                                ),
                              ),
                              icon: const Icon(Icons.add),
                              label: const Text('Novo Solo'),
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

                        final soil = soils[index];
                        final isSelected = soil.id == widget.selectedSoilId;

                        return _SoilListTile(
                          soil: soil,
                          isSelected: isSelected,
                          onTap: () => Navigator.pop(context, soil),
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

class _SoilListTile extends StatelessWidget {
  final SoilModel soil;
  final bool isSelected;
  final VoidCallback onTap;

  const _SoilListTile({
    required this.soil,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
                  image: soil.imagePath != null
                      ? DecorationImage(
                          image: soil.imagePath!.startsWith('assets/')
                              ? AssetImage(soil.imagePath!) as ImageProvider
                              : FileImage(File(soil.imagePath!)),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: soil.imagePath == null
                    ? const Icon(Icons.terrain_outlined, color: Colors.white70)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      soil.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (soil.composition != null)
                      Text(
                        soil.composition!,
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
