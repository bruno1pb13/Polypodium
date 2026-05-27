import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../domain/soil_model.dart';
import '../providers/soils_providers.dart';

class AddEditSoilScreen extends ConsumerStatefulWidget {
  final SoilModel? soil;

  const AddEditSoilScreen({super.key, this.soil});

  @override
  ConsumerState<AddEditSoilScreen> createState() => _AddEditSoilScreenState();
}

class _AddEditSoilScreenState extends ConsumerState<AddEditSoilScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _compositionCtrl;
  bool _saving = false;

  bool get _isEditing => widget.soil != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.soil?.name ?? '');
    _compositionCtrl = TextEditingController(text: widget.soil?.composition ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _compositionCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final soil = SoilModel(
        id: widget.soil?.id ?? const Uuid().v4(),
        name: _nameCtrl.text.trim(),
        composition: _compositionCtrl.text.trim().isEmpty ? null : _compositionCtrl.text.trim(),
        createdAt: widget.soil?.createdAt ?? DateTime.now(),
      );

      await ref.read(soilsNotifierProvider.notifier).save(soil);
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Solo' : 'Novo Solo'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Nome do Solo *',
                hintText: 'Ex: Solo Orgânico Premium',
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe um nome' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _compositionCtrl,
              decoration: const InputDecoration(
                labelText: 'Composição (opcional)',
                hintText: 'Ex: 40% húmus, 30% perlita, 30% fibra de coco',
                helperText: 'Uma linha descrevendo a mistura do solo.',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _saving ? null : _submit,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(_isEditing ? 'Salvar' : 'Adicionar'),
            ),
          ],
        ),
      ),
    );
  }
}
