import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/l10n/l10n.dart';
import '../../domain/species_model.dart';
import '../../data/external_species_repository.dart';

class SpeciesAutocomplete extends ConsumerStatefulWidget {
  final List<SpeciesModel> localSpecies;
  final TextEditingController controller;
  final void Function(String? id, String? popular, String? scientific) onSelected;

  /// Defaults to the localized "Species *" label when null.
  final String? label;

  /// Defaults to the localized search hint when null.
  final String? hint;
  final String? Function(String?)? validator;

  const SpeciesAutocomplete({
    super.key,
    required this.localSpecies,
    required this.controller,
    required this.onSelected,
    this.label,
    this.hint,
    this.validator,
  });

  @override
  ConsumerState<SpeciesAutocomplete> createState() => _SpeciesAutocompleteState();
}

class _SpeciesAutocompleteState extends ConsumerState<SpeciesAutocomplete> {
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  List<Object> _options = [];
  bool _isLoading = false;
  bool _ignoreNextQueryChange = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
    widget.controller.addListener(_onQueryChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    widget.controller.removeListener(_onQueryChange);
    _focusNode.dispose();
    _debounce?.cancel();
    _removeOverlay();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      _updateOptions();
    } else {
      _debounce?.cancel(); // Cancel search if we lose focus
      // Delay removal to allow tapping on options
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && !_focusNode.hasFocus) {
          _removeOverlay();
        }
      });
    }
  }

  void _onQueryChange() {
    if (_ignoreNextQueryChange) {
      _ignoreNextQueryChange = false;
      return;
    }
    if (_focusNode.hasFocus) {
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), _updateOptions);
    }
  }

  Future<void> _updateOptions() async {
    if (!mounted) return;
    final query = widget.controller.text;
    
    // 1. Filter Local (Immediate)
    final List<SpeciesModel> locals;
    if (query.isEmpty) {
      locals = widget.localSpecies.take(10).toList();
    } else {
      final normalizedQuery = query.toLowerCase();
      locals = widget.localSpecies
          .where((s) =>
              s.popularName.toLowerCase().contains(normalizedQuery) ||
              s.scientificName.toLowerCase().contains(normalizedQuery))
          .toList();
    }

    // 2. Search External (Async)
    if (query.isEmpty) {
      if (mounted && _focusNode.hasFocus) {
        setState(() {
          _options = locals;
          _isLoading = false;
        });
        _showOverlay();
      }
      return;
    }

    setState(() {
      _options = locals;
      _isLoading = true;
    });
    _showOverlay(); // Show overlay immediately with local results and loading indicator

    try {
      final externals = await ref
          .read(externalSpeciesRepositoryProvider.notifier)
          .search(query);

      if (mounted) {
        setState(() {
          _isLoading = false;
          if (_focusNode.hasFocus) {
            _options = [...locals, ...externals];
            _showOverlay();
          }
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showOverlay() {
    if (!mounted) return;
    
    // If already showing, we just mark it for rebuild
    if (_overlayEntry != null) {
      _overlayEntry!.markNeedsBuild();
      return;
    }

    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 5),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(8),
            clipBehavior: Clip.antiAlias,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 250),
              child: StatefulBuilder(
                builder: (context, setOverlayState) {
                  // This allows the overlay to react to _isLoading and _options changes
                  // since it is in a different build context
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isLoading && _options.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                        ),
                      if (_options.isNotEmpty)
                        Flexible(
                          child: ListView.separated(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            itemCount: _options.length,
                            separatorBuilder: (ctx, i) => const Divider(height: 1),
                            itemBuilder: (ctx, i) {
                              final option = _options[i];
                              String title;
                              String subtitle;
                              bool isLocal = false;

                              if (option is SpeciesModel) {
                                title = option.popularName;
                                subtitle = option.scientificName;
                                isLocal = true;
                              } else {
                                final ext = option as ExternalSpecies;
                                title = ext.popularName;
                                subtitle = ext.scientificName;
                              }

                              return ListTile(
                                dense: true,
                                title: Text(title, style: const TextStyle(fontSize: 14)),
                                subtitle: Text(
                                  subtitle,
                                  style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                                ),
                                trailing: Icon(
                                  isLocal ? Icons.star : Icons.public,
                                  size: 16,
                                  color: isLocal ? Colors.amber : Colors.grey,
                                ),
                                onTap: () {
                                  _debounce?.cancel(); // Cancel any pending search
                                  _ignoreNextQueryChange = true;
                                  
                                  // Update loading state immediately to avoid "None found" message
                                  setState(() {
                                    _isLoading = false;
                                    _options = [];
                                  });

                                  if (option is SpeciesModel) {
                                    widget.onSelected(option.id, option.popularName, option.scientificName);
                                    widget.controller.text = '${option.popularName} (${option.scientificName})';
                                  } else if (option is ExternalSpecies) {
                                    widget.onSelected(null, option.popularName, option.scientificName);
                                    widget.controller.text = '${option.popularName} (${option.scientificName})';
                                  }
                                  _focusNode.unfocus();
                                  _removeOverlay();
                                },
                              );
                            },
                          ),
                        ),
                      if (!_isLoading && _options.isEmpty && widget.controller.text.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(context.l10n.noSpeciesFound,
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey)),
                        ),
                    ],
                  );
                }
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        decoration: InputDecoration(
          labelText: widget.label ?? '${context.l10n.speciesFieldLabel} *',
          hintText: widget.hint ?? context.l10n.speciesSearchFieldHint,
          suffixIcon: _isLoading 
            ? const SizedBox(width: 20, height: 20, child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2)))
            : const Icon(Icons.search, size: 20),
        ),
        validator: widget.validator,
        onTap: () {
          if (!_focusNode.hasFocus) {
            _focusNode.requestFocus();
          } else {
            _updateOptions();
          }
        },
      ),
    );
  }
}
