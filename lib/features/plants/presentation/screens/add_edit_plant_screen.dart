import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/enums.dart';
import '../../../species/domain/species_model.dart';
import '../../../species/presentation/providers/species_providers.dart';
import '../../../species/presentation/widgets/species_autocomplete.dart';
import '../../../locations/presentation/providers/locations_providers.dart';
import '../../../locations/presentation/screens/add_edit_location_screen.dart';
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
  late final TextEditingController _speciesSearchCtrl;
  late final TextEditingController _frequencyCtrl;

  String? _selectedSpeciesId;
  String? _tempExternalPopularName;
  String? _tempExternalScientificName;

  String? _selectedLocationId;
  SoilType _soilType = SoilType.loamy;
  DateTime _acquisitionDate = DateTime.now();

  bool _isFrequencyAutoFilled = false;
  bool _isSoilAutoFilled = false;

  bool get _isEditing => widget.plant != null;

  @override
  void initState() {
    super.initState();
    final p = widget.plant;
    _nicknameCtrl = TextEditingController(text: p?.nickname ?? '');
    _speciesSearchCtrl = TextEditingController();
    _frequencyCtrl = TextEditingController(
      text: p?.irrigationFrequencyDays?.toString() ?? '',
    );
    _selectedSpeciesId = p?.speciesId;
    _selectedLocationId = p?.locationId;
    _soilType = p?.soilType ?? SoilType.loamy;
    _acquisitionDate = p?.acquisitionDate ?? DateTime.now();

    // If editing, we need to load the species name into the search field
    if (_isEditing && _selectedSpeciesId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final speciesList = await ref.read(speciesNotifierProvider.future);
        final match = speciesList.cast<SpeciesModel?>().firstWhere(
              (s) => s?.id == _selectedSpeciesId,
              orElse: () => null,
            );
        if (match != null) {
          setState(() {
            _speciesSearchCtrl.text =
                '${match.popularName} (${match.scientificName})';
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _nicknameCtrl.dispose();
    _speciesSearchCtrl.dispose();
    _frequencyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final speciesAsync = ref.watch(speciesNotifierProvider);
    final locationsAsync = ref.watch(locationsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar planta' : 'Nova planta'),
      ),
      body: speciesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (species) => locationsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Erro: $e')),
          data: (locations) => Form(
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
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Informe um apelido'
                      : null,
                ),
                const SizedBox(height: 16),
                SpeciesAutocomplete(
                  localSpecies: species,
                  controller: _speciesSearchCtrl,
                  onSelected: (id, popular, scientific) {
                    setState(() {
                      _selectedSpeciesId = id;
                      _tempExternalPopularName = popular;
                      _tempExternalScientificName = scientific;

                      if (id != null) {
                        // Local species selected
                        final selectedSpecies =
                            species.firstWhere((s) => s.id == id);
                        
                        if (selectedSpecies.defaultIrrigationFrequencyDays != null) {
                          _frequencyCtrl.text = selectedSpecies
                              .defaultIrrigationFrequencyDays
                              .toString();
                          _isFrequencyAutoFilled = true;
                        } else {
                          _frequencyCtrl.text = '';
                          _isFrequencyAutoFilled = false;
                        }

                        if (selectedSpecies.recommendedSoilTypes.isNotEmpty) {
                          _soilType =
                              selectedSpecies.recommendedSoilTypes.first;
                          _isSoilAutoFilled = true;
                        }
                      } else {
                        // External species selected (will be created on submit)
                        _frequencyCtrl.text = ''; 
                        _isFrequencyAutoFilled = false;
                        _isSoilAutoFilled = false;
                      }
                    });
                  },
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Selecione uma espécie'
                      : null,
                ),
                const SizedBox(height: 16),
                _SoilTypeDropdown(
                  value: _soilType,
                  isRecommended: _isSoilAutoFilled,
                  onChanged: (v) {
                    setState(() {
                      _soilType = v!;
                      _isSoilAutoFilled = false;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _frequencyCtrl,
                  decoration: InputDecoration(
                    labelText:
                        'Frequência de irrigação (dias)${_isFrequencyAutoFilled ? ' (recomendado)' : ''} *',
                    hintText: 'Informe o intervalo entre regas',
                  ),
                  onChanged: (_) {
                    if (_isFrequencyAutoFilled) {
                      setState(() => _isFrequencyAutoFilled = false);
                    }
                  },
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Informe a frequência de irrigação';
                    }
                    final n = int.tryParse(v);
                    if (n == null || n <= 0) {
                      return 'Informe um número positivo';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        // ignore: deprecated_member_use
                        value: _selectedLocationId,
                        decoration: const InputDecoration(
                          labelText: 'Localização',
                        ),
                        items: locations
                            .map((l) => DropdownMenuItem(
                                  value: l.id,
                                  child: Text(l.name),
                                ))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _selectedLocationId = v),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.add_location_alt_outlined),
                      tooltip: 'Nova localização',
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddEditLocationScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Data de aquisição'),
                  subtitle:
                      Text(DateFormat('dd/MM/yyyy').format(_acquisitionDate)),
                  trailing: const Icon(Icons.calendar_today_outlined),
                  onTap: _pickDate,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _submit,
                  child: Text(
                      _isEditing ? 'Salvar alterações' : 'Adicionar planta'),
                ),
              ],
            ),
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

    if (_selectedSpeciesId == null && _tempExternalScientificName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione uma espécie da lista')),
      );
      return;
    }

    // Get or create local species ID
    String finalSpeciesId;
    if (_selectedSpeciesId != null) {
      finalSpeciesId = _selectedSpeciesId!;
    } else {
      // Create from external
      finalSpeciesId = await ref
          .read(speciesNotifierProvider.notifier)
          .getOrCreateFromExternal(
            popularName: _tempExternalPopularName!,
            scientificName: _tempExternalScientificName!,
          );
    }

    final frequencyText = _frequencyCtrl.text.trim();
    final plant = PlantModel(
      id: widget.plant?.id ?? const Uuid().v4(),
      speciesId: finalSpeciesId,
      nickname: _nicknameCtrl.text.trim(),
      soilType: _soilType,
      irrigationFrequencyDays:
          frequencyText.isEmpty ? null : int.parse(frequencyText),
      acquisitionDate: _acquisitionDate,
      locationId: _selectedLocationId,
      lastIrrigatedAt: widget.plant?.lastIrrigatedAt,
      createdAt: widget.plant?.createdAt ?? DateTime.now(),
    );

    await ref.read(plantsNotifierProvider.notifier).save(plant);
    if (mounted) Navigator.pop(context);
  }
}

class _SoilTypeDropdown extends StatelessWidget {
  final SoilType value;
  final bool isRecommended;
  final ValueChanged<SoilType?> onChanged;

  const _SoilTypeDropdown({
    required this.value,
    this.isRecommended = false,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<SoilType>(
      // ignore: deprecated_member_use
      value: value,
      decoration: InputDecoration(
        labelText: 'Tipo de solo *${isRecommended ? ' (recomendado)' : ''}',
      ),
      items: SoilType.values
          .map((s) => DropdownMenuItem(value: s, child: Text(s.label)))
          .toList(),
      onChanged: onChanged,
    );
  }
}
