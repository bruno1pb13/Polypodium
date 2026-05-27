import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../domain/location_model.dart';
import '../providers/locations_providers.dart';

class AddEditLocationScreen extends ConsumerStatefulWidget {
  final LocationModel? location;

  const AddEditLocationScreen({super.key, this.location});

  @override
  ConsumerState<AddEditLocationScreen> createState() =>
      _AddEditLocationScreenState();
}

class _AddEditLocationScreenState extends ConsumerState<AddEditLocationScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descriptionCtrl;
  late final TextEditingController _latitudeCtrl;
  late final TextEditingController _longitudeCtrl;
  bool _saving = false;

  bool get _isEditing => widget.location != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.location?.name ?? '');
    _descriptionCtrl =
        TextEditingController(text: widget.location?.description ?? '');
    _latitudeCtrl = TextEditingController(
        text: widget.location?.latitude?.toString() ?? '');
    _longitudeCtrl = TextEditingController(
        text: widget.location?.longitude?.toString() ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descriptionCtrl.dispose();
    _latitudeCtrl.dispose();
    _longitudeCtrl.dispose();
    super.dispose();
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
          _isEditing ? 'Editar localização' : 'Nova localização',
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SectionTitle('Identificação'),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _nameCtrl,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              labelText: 'Nome *',
                              hintText: 'Ex: Sala de estar, Varanda, Quarto',
                              prefixIcon: Icon(Icons.location_on_outlined),
                            ),
                            textCapitalization: TextCapitalization.sentences,
                            validator: (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? 'Campo obrigatório'
                                    : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _descriptionCtrl,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              labelText: 'Descrição',
                              hintText: 'Opcional',
                              prefixIcon: Icon(Icons.notes_outlined),
                            ),
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SectionTitle('Coordenadas'),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _latitudeCtrl,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: const InputDecoration(
                                    labelText: 'Latitude',
                                    hintText: 'Opcional',
                                    prefixIcon: Icon(Icons.explore_outlined),
                                  ),
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          signed: true, decimal: true),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'[0-9eE\.\-+]')),
                                  ],
                                  validator: (v) =>
                                      _validateCoordinate(v, -90, 90),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _longitudeCtrl,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: const InputDecoration(
                                    labelText: 'Longitude',
                                    hintText: 'Opcional',
                                    prefixIcon: Icon(Icons.explore_outlined),
                                  ),
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          signed: true, decimal: true),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'[0-9eE\.\-+]')),
                                  ],
                                  validator: (v) =>
                                      _validateCoordinate(v, -180, 180),
                                ),
                              ),
                            ],
                          ),
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
                                _isEditing
                                    ? 'Salvar alterações'
                                    : 'Adicionar localização',
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

  String? _validateCoordinate(String? v, double min, double max) {
    if (v == null || v.trim().isEmpty) return null;
    final parsed = double.tryParse(v.trim());
    if (parsed == null) return 'Número inválido';
    if (parsed < min || parsed > max) return 'Fora do intervalo [$min, $max]';
    return null;
  }

  double? _parseCoordinate(TextEditingController ctrl) {
    final text = ctrl.text.trim();
    if (text.isEmpty) return null;
    return double.tryParse(text);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final location = LocationModel(
        id: widget.location?.id ?? const Uuid().v4(),
        name: _nameCtrl.text.trim(),
        description: _descriptionCtrl.text.trim().isEmpty
            ? null
            : _descriptionCtrl.text.trim(),
        latitude: _parseCoordinate(_latitudeCtrl),
        longitude: _parseCoordinate(_longitudeCtrl),
        createdAt: widget.location?.createdAt ?? DateTime.now(),
      );
      await ref.read(locationsNotifierProvider.notifier).save(location);
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
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
