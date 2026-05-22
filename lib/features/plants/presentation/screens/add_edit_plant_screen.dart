import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/enums.dart';
import '../../../species/domain/species_model.dart';
import '../../../species/presentation/providers/species_providers.dart';
import '../../domain/plant_model.dart';
import '../providers/plants_providers.dart';

class AddEditPlantScreen extends ConsumerStatefulWidget {
  final PlantModel? plant;

  const AddEditPlantScreen({super.key, this.plant});

  @override
  ConsumerState<AddEditPlantScreen> createState() => _AddEditPlantScreenState();
}

class _AddEditPlantScreenState extends ConsumerState<AddEditPlantScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nicknameCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _frequencyCtrl;

  String? _selectedSpeciesId;
  SoilType _soilType = SoilType.loamy;
  DateTime _acquisitionDate = DateTime.now();

  bool get _isEditing => widget.plant != null;

  @override
  void initState() {
    super.initState();
    final p = widget.plant;
    _nicknameCtrl = TextEditingController(text: p?.nickname ?? '');
    _locationCtrl = TextEditingController(text: p?.location ?? '');
    _frequencyCtrl = TextEditingController(
      text: p?.irrigationFrequencyDays?.toString() ?? '',
    );
    _selectedSpeciesId = p?.speciesId;
    _soilType = p?.soilType ?? SoilType.loamy;
    _acquisitionDate = p?.acquisitionDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _nicknameCtrl.dispose();
    _locationCtrl.dispose();
    _frequencyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final speciesAsync = ref.watch(speciesNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar planta' : 'Nova planta'),
      ),
      body: speciesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (species) => Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _nicknameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Apelido *',
                  hintText: 'Ex: Samambaia da sala',
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Informe um apelido' : null,
              ),
              const SizedBox(height: 16),
              _SpeciesDropdown(
                species: species,
                selected: _selectedSpeciesId,
                onChanged: (id) => setState(() => _selectedSpeciesId = id),
              ),
              const SizedBox(height: 16),
              _SoilTypeDropdown(
                value: _soilType,
                onChanged: (v) => setState(() => _soilType = v!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _frequencyCtrl,
                decoration: const InputDecoration(
                  labelText: 'Frequência de irrigação (dias)',
                  hintText: 'Deixe vazio para usar o padrão da espécie',
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return null;
                  final n = int.tryParse(v);
                  if (n == null || n <= 0) return 'Informe um número positivo';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationCtrl,
                decoration: const InputDecoration(
                  labelText: 'Localização',
                  hintText: 'Ex: Varanda, quarto',
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Data de aquisição'),
                subtitle: Text(DateFormat('dd/MM/yyyy').format(_acquisitionDate)),
                trailing: const Icon(Icons.calendar_today_outlined),
                onTap: _pickDate,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _submit,
                child: Text(_isEditing ? 'Salvar alterações' : 'Adicionar planta'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _acquisitionDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _acquisitionDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSpeciesId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione uma espécie')),
      );
      return;
    }

    final frequencyText = _frequencyCtrl.text.trim();
    final plant = PlantModel(
      id: widget.plant?.id ?? const Uuid().v4(),
      speciesId: _selectedSpeciesId!,
      nickname: _nicknameCtrl.text.trim(),
      soilType: _soilType,
      irrigationFrequencyDays:
          frequencyText.isEmpty ? null : int.parse(frequencyText),
      acquisitionDate: _acquisitionDate,
      location: _locationCtrl.text.trim().isEmpty
          ? null
          : _locationCtrl.text.trim(),
      lastIrrigatedAt: widget.plant?.lastIrrigatedAt,
      createdAt: widget.plant?.createdAt ?? DateTime.now(),
    );

    await ref.read(plantsNotifierProvider.notifier).save(plant);
    if (mounted) Navigator.pop(context);
  }
}

class _SpeciesDropdown extends StatelessWidget {
  final List<SpeciesModel> species;
  final String? selected;
  final ValueChanged<String?> onChanged;

  const _SpeciesDropdown({
    required this.species,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: selected,
      decoration: const InputDecoration(labelText: 'Espécie *'),
      items: species
          .map((s) => DropdownMenuItem(
                value: s.id,
                child: Text('${s.popularName} (${s.scientificName})'),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }
}

class _SoilTypeDropdown extends StatelessWidget {
  final SoilType value;
  final ValueChanged<SoilType?> onChanged;

  const _SoilTypeDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<SoilType>(
      initialValue: value,
      decoration: const InputDecoration(labelText: 'Tipo de solo *'),
      items: SoilType.values
          .map((s) => DropdownMenuItem(value: s, child: Text(s.label)))
          .toList(),
      onChanged: onChanged,
    );
  }
}
