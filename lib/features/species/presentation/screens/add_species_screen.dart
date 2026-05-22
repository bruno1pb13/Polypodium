import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/enums.dart';
import '../../domain/species_model.dart';
import '../providers/species_providers.dart';

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

  Set<SoilType> _soilTypes = {};
  bool _saving = false;

  bool get _isEditing => widget.species != null;

  @override
  void initState() {
    super.initState();
    final s = widget.species;
    _scientificCtrl = TextEditingController(text: s?.scientificName ?? '');
    _popularCtrl = TextEditingController(text: s?.popularName ?? '');
    _frequencyCtrl = TextEditingController(
      text: s?.defaultIrrigationFrequencyDays.toString() ?? '7',
    );
    _soilTypes = s?.recommendedSoilTypes.toSet() ?? {};
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
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar espécie' : 'Nova espécie'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _popularCtrl,
              decoration: const InputDecoration(
                labelText: 'Nome popular *',
                hintText: 'Ex: Samambaia',
              ),
              textCapitalization: TextCapitalization.words,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Campo obrigatório' : null,
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
                labelText: 'Frequência de irrigação padrão (dias) *',
              ),
              keyboardType: TextInputType.number,
              validator: (v) {
                final n = int.tryParse(v ?? '');
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
              children: SoilType.values.map((soil) {
                final selected = _soilTypes.contains(soil);
                return FilterChip(
                  label: Text(soil.label),
                  selected: selected,
                  onSelected: (on) => setState(() {
                    on ? _soilTypes.add(soil) : _soilTypes.remove(soil);
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
                  : Text(_isEditing ? 'Salvar alterações' : 'Adicionar espécie'),
            ),
          ],
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
        defaultIrrigationFrequencyDays: int.parse(_frequencyCtrl.text.trim()),
        recommendedSoilTypes: _soilTypes.toList(),
        createdAt: widget.species?.createdAt ?? DateTime.now(),
      );
      await ref.read(speciesNotifierProvider.notifier).save(species);
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
