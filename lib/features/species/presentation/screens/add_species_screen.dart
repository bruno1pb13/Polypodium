import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../soils/presentation/providers/soils_providers.dart';
import '../../domain/species_model.dart';
import '../providers/species_providers.dart';
import '../widgets/species_autocomplete.dart';

class AddSpeciesScreen extends ConsumerStatefulWidget {
  final SpeciesModel? species;

  const AddSpeciesScreen({super.key, this.species});

  @override
  ConsumerState<AddSpeciesScreen> createState() => _AddSpeciesScreenState();
}

class _AddSpeciesScreenState extends ConsumerState<AddSpeciesScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _scientificCtrl;
  late final TextEditingController _popularCtrl;
  late final TextEditingController _frequencyCtrl;

  Set<String> _soilIds = {};
  bool _saving = false;

  bool get _isEditing => widget.species != null;

  @override
  void initState() {
    super.initState();
    final s = widget.species;
    _scientificCtrl = TextEditingController(text: s?.scientificName ?? '');
    _popularCtrl = TextEditingController(text: s?.popularName ?? '');
    _frequencyCtrl = TextEditingController(
      text: s?.defaultIrrigationFrequencyDays?.toString() ?? '',
    );
    _soilIds = s?.recommendedSoilIds.toSet() ?? {};
  }

  @override
  void dispose() {
    _scientificCtrl.dispose();
    _popularCtrl.dispose();
    _frequencyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final soilsAsync = ref.watch(soilsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar espécie' : 'Nova espécie'),
      ),
      body: soilsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (soils) => Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SpeciesAutocomplete(
                localSpecies: const [], // Na tela de espécie só queremos buscar na base externa
                controller: _popularCtrl,
                label: 'Nome popular *',
                onSelected: (_, popular, scientific) {
                  setState(() {
                    _popularCtrl.text = popular!;
                    _scientificCtrl.text = scientific!;
                  });
                },
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Campo obrigatório'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _scientificCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nome científico *',
                  hintText: 'Ex: Nephrolepis exaltata',
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _frequencyCtrl,
                decoration: const InputDecoration(
                  labelText: 'Frequência de irrigação padrão (dias)',
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  final n = int.tryParse(v);
                  if (n == null || n <= 0) return 'Informe um número positivo';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Solos recomendados',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: soils.map((soil) {
                  final selected = _soilIds.contains(soil.id);
                  return FilterChip(
                    label: Text(soil.name),
                    selected: selected,
                    onSelected: (on) => setState(() {
                      on ? _soilIds.add(soil.id) : _soilIds.remove(soil.id);
                    }),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _saving ? null : _submit,
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        _isEditing ? 'Salvar alterações' : 'Adicionar espécie'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final species = SpeciesModel(
        id: widget.species?.id ?? const Uuid().v4(),
        scientificName: _scientificCtrl.text.trim(),
        popularName: _popularCtrl.text.trim(),
        defaultIrrigationFrequencyDays:
            _frequencyCtrl.text.trim().isEmpty
                ? null
                : int.parse(_frequencyCtrl.text.trim()),
        recommendedSoilIds: _soilIds.toList(),
        createdAt: widget.species?.createdAt ?? DateTime.now(),
      );
      await ref.read(speciesNotifierProvider.notifier).save(species);
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
