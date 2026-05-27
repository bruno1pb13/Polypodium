import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
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
  late final TextEditingController _sourceCtrl;
  String? _imagePath;
  bool _saving = false;

  bool get _isEditing => widget.soil != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.soil?.name ?? '');
    _compositionCtrl =
        TextEditingController(text: widget.soil?.composition ?? '');
    _sourceCtrl = TextEditingController(text: widget.soil?.imageSource ?? '');
    _imagePath = widget.soil?.imagePath;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _compositionCtrl.dispose();
    _sourceCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _imagePath = image.path);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      String? finalImagePath = _imagePath;

      // Se a imagem mudou e não é um asset, salvar no diretório do app
      if (_imagePath != null &&
          !_imagePath!.startsWith('assets/') &&
          _imagePath != widget.soil?.imagePath) {
        final dir = await getApplicationDocumentsDirectory();
        final name = '${const Uuid().v4()}${p.extension(_imagePath!)}';
        final savedFile = await File(_imagePath!).copy(p.join(dir.path, name));
        finalImagePath = savedFile.path;
      }

      final soil = SoilModel(
        id: widget.soil?.id ?? const Uuid().v4(),
        name: _nameCtrl.text.trim(),
        composition: _compositionCtrl.text.trim().isEmpty
            ? null
            : _compositionCtrl.text.trim(),
        imagePath: finalImagePath,
        imageSource:
            _sourceCtrl.text.trim().isEmpty ? null : _sourceCtrl.text.trim(),
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
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                    image: _imagePath != null
                        ? DecorationImage(
                            image: _imagePath!.startsWith('assets/')
                                ? AssetImage(_imagePath!) as ImageProvider
                                : FileImage(File(_imagePath!)),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _imagePath == null
                      ? const Icon(Icons.add_a_photo_outlined, size: 40)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'Toque para alterar a imagem',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Nome do Solo *',
                hintText: 'Ex: Solo Orgânico Premium',
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Informe um nome' : null,
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
            const SizedBox(height: 16),
            TextFormField(
              controller: _sourceCtrl,
              decoration: const InputDecoration(
                labelText: 'Fonte da Imagem (opcional)',
                hintText: 'Ex: https://exemplo.com/foto',
              ),
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _saving ? null : _submit,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(_isEditing ? 'Salvar' : 'Adicionar'),
            ),
          ],
        ),
      ),
    );
  }
}
