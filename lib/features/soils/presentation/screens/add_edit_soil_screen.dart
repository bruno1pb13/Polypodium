import 'dart:io';
import 'dart:ui';

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
  bool get _isAssetImage => _imagePath?.startsWith('assets/') ?? false;

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
      setState(() {
        _imagePath = image.path;
        _sourceCtrl.clear();
      });
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
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          _isEditing ? 'Editar solo' : 'Novo solo',
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
            child: Theme(
              data: _darkFormTheme(context),
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset),
                  children: [
                    _GlassCard(
                      child: Column(
                        children: [
                          Center(
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                width: 160,
                                height: 160,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.2)),
                                  image: _imagePath != null
                                      ? DecorationImage(
                                          image: _imagePath!.startsWith('assets/')
                                              ? AssetImage(_imagePath!)
                                                  as ImageProvider
                                              : FileImage(File(_imagePath!)),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: _imagePath == null
                                    ? const Icon(Icons.add_a_photo_outlined,
                                        size: 48, color: Colors.white70)
                                    : null,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Toque para alterar a imagem',
                            style: TextStyle(fontSize: 12, color: Colors.white60),
                          ),
                          if (_isAssetImage && _sourceCtrl.text.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Fonte: ${_sourceCtrl.text}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.white54,
                                  fontStyle: FontStyle.italic),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SectionTitle('Informações'),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _nameCtrl,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              labelText: 'Nome do Solo *',
                              hintText: 'Ex: Solo Orgânico Premium',
                              prefixIcon: Icon(Icons.terrain_outlined),
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Informe um nome'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _compositionCtrl,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              labelText: 'Composição (opcional)',
                              hintText:
                                  'Ex: 40% húmus, 30% perlita, 30% fibra de coco',
                              helperText: 'Uma linha descrevendo a mistura.',
                              prefixIcon: Icon(Icons.layers_outlined),
                            ),
                            maxLines: 2,
                          ),
                          if (!_isAssetImage) ...[
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _sourceCtrl,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                labelText: 'Fonte da Imagem (opcional)',
                                hintText: 'Ex: https://exemplo.com/foto',
                                prefixIcon: Icon(Icons.link_outlined),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      height: 56,
                      child: FilledButton(
                        onPressed: _saving ? null : _submit,
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _saving
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                _isEditing ? 'Salvar alterações' : 'Criar solo',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

ThemeData _darkFormTheme(BuildContext context) {
  final base = Theme.of(context);
  final primary = base.colorScheme.primary;
  OutlineInputBorder border([Color color = Colors.white24]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color),
      );

  return base.copyWith(
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.05),
      labelStyle: const TextStyle(color: Colors.white70),
      floatingLabelStyle: TextStyle(color: primary),
      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
      helperStyle: const TextStyle(color: Colors.white60),
      prefixIconColor: Colors.white70,
      suffixIconColor: Colors.white70,
      iconColor: Colors.white70,
      border: border(),
      enabledBorder: border(),
      focusedBorder: border(primary),
      errorBorder: border(base.colorScheme.error),
      focusedErrorBorder: border(base.colorScheme.error),
      errorStyle: TextStyle(color: base.colorScheme.error),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: primary,
      selectionColor: primary.withValues(alpha: 0.4),
      selectionHandleColor: primary,
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;

  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: child,
        ),
      ),
    );
  }
}
