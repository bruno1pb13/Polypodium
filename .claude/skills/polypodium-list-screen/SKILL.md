---
name: polypodium-list-screen
description: Build or update a Polypodium list screen (lista, listagem, tela de listagem) so it matches the established glass-card-over-background-image aesthetic used by HomeScreen + PlantListItem. Use whenever the user asks to create, atualizar, padronizar, estilizar or alinhar uma "tela de listagem" (species, locations, soils, entries, etc.) com a identidade visual do app.
---

# Polypodium List Screen Pattern

This skill governs **list/listing screens only**. For form/edit screens use `polypodium-style`. The two skills share the same background+AppBar shell but differ in body layout, item shape, and helpers.

## When to invoke

- The user asks to create or update a *listagem* / *tela de listagem* / *lista de X*.
- A list screen is still using default Material `ListTile`s with no background image.
- The user says "como a tela de plantas", "no padrão", "estilizar a listagem", or names list screens explicitly (species/locations/soils/entries).

## Authoritative references

Always re-read these before writing — they are the source of truth. If they diverge from this skill, the files win and this skill should be updated.

- Reference list screen → `lib/features/plants/presentation/screens/home_screen.dart`
- Reference list item → `lib/features/plants/presentation/widgets/plant_list_item.dart`
- Already-aligned examples → `lib/features/species/presentation/screens/species_list_screen.dart`, `lib/features/locations/presentation/screens/locations_list_screen.dart`, `lib/features/soils/presentation/screens/soils_list_screen.dart`

## Required structure

A compliant list screen has three pieces, in this exact order in the file:

1. The `ConsumerWidget` screen class.
2. A private `_XxxListItem extends ConsumerWidget` that watches `transparencyEnabledNotifierProvider`.
3. A private `_EmptyState extends StatelessWidget`.

Optional additional private widgets (e.g. `_InfoBanner`) live between the screen and the list item.

### Scaffold

```dart
Scaffold(
  resizeToAvoidBottomInset: false,
  extendBodyBehindAppBar: true,
  appBar: AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    iconTheme: const IconThemeData(color: Colors.white),
    title: const Text(
      'Título',
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
      ),
    ),
  ),
  body: Stack(children: [/* background + gradient + SafeArea */]),
  floatingActionButton: FloatingActionButton(
    onPressed: ...,
    child: const Icon(Icons.add),
  ),
)
```

Keep the default Material `FloatingActionButton` — never restyle it.

### Background stack (three layers, in order)

```dart
body: Stack(
  children: [
    Positioned.fill(
      child: Image.asset('assets/images/background.png', fit: BoxFit.cover),
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
    SafeArea(child: /* AsyncValue.when */),
  ],
)
```

### AsyncValue handling

```dart
asyncValue.when(
  loading: () => const Center(
    child: CircularProgressIndicator(color: Colors.white),
  ),
  error: (e, _) => Center(
    child: Text('Erro: $e', style: const TextStyle(color: Colors.white)),
  ),
  data: (items) {
    if (items.isEmpty) return const _EmptyState();
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 80),
      itemCount: items.length,
      itemBuilder: (ctx, i) => _XxxListItem(
        model: items[i],
        onEdit: () => Navigator.push(...),
        onDelete: () => _confirmDelete(context, ref, items[i].id),
      ),
    );
  },
)
```

`bottom: 80` is mandatory so the last row clears the FAB. Loading/error states must use the dark palette (white text, white spinner) — Material defaults look broken over the dark background.

## The list item

Every list row is a private `_XxxListItem extends ConsumerWidget` so it can watch `transparencyEnabledNotifierProvider`. The transparency toggle is non-negotiable — every other list item in the app honors it and a glass-only widget would break user choice.

Shape (outer to inner):

```dart
Padding(horizontal: 16, vertical: 6)
└─ ClipRRect(radius: 16)
   └─ BackdropFilter(blur: transparencyEnabled ? 10 : 0)
      └─ Container(
            color: transparencyEnabled
                ? Colors.black.withValues(alpha: 0.35)
                : colorScheme.surfaceContainerHighest,
            border: transparencyEnabled
                ? Border.all(color: Colors.white.withValues(alpha: 0.1))
                : Border.all(color: Colors.transparent),
         )
         └─ InkWell(onTap: onEdit, borderRadius: 16)
            └─ Padding(all: 12)
               └─ Row([leadingIcon, Expanded(text), trailing IconButtons])
```

### Leading icon

48×48 rounded square (`borderRadius: 12`). Color logic:

```dart
color: transparencyEnabled
    ? Colors.white.withValues(alpha: 0.1)
    : colorScheme.primaryContainer,
// Icon color:
color: transparencyEnabled ? Colors.white : colorScheme.primary,
```

If the row has a real photo (like plants), use a `ClipRRect`-wrapped `Image.file` of size 72×72 instead. Otherwise stick with the 48×48 icon tile.

### Title

```dart
Text(
  model.name,
  style: TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 16, // 17 if the row has a 72×72 photo, like plants
    color: transparencyEnabled
        ? Colors.white
        : colorScheme.onSurfaceVariant,
    shadows: transparencyEnabled
        ? [const Shadow(color: Colors.black26, offset: Offset(0, 1), blurRadius: 2)]
        : null,
  ),
)
```

### Subtitle

13px, white70 when transparent, `onSurfaceVariant.withValues(alpha: 0.7)` when solid. Wrap nullable subtitles in `if (model.field != null && model.field!.isNotEmpty) ...[ const SizedBox(height: 2), Text(...) ]` so missing values don't leave dead space.

### Trailing icons

Use `IconButton` with `Icons.edit_outlined` and `Icons.delete_outline`. Color:

```dart
color: transparencyEnabled ? Colors.white70 : colorScheme.onSurfaceVariant,
```

## Empty state

```dart
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(<entity icon>, size: 64,
              color: Colors.white.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          const Text('<Nenhum X cadastrado>',
              style: TextStyle(color: Colors.white, fontSize: 16)),
          const SizedBox(height: 8),
          const Text('Toque em + para adicionar ...',
              style: TextStyle(fontSize: 13, color: Colors.white70)),
        ],
      ),
    );
  }
}
```

The icon should be the entity's canonical icon (e.g. `Icons.eco_outlined` for species, `Icons.location_on_outlined` for locations, `Icons.terrain_outlined` for soils).

## Info / utility banners

If the screen has a banner (info text, dataset version, action button), place it inside `SafeArea` above the `Expanded` list and use the same glass card shape as a list item (radius 16, translucent black or `surfaceContainerHighest`, honoring `transparencyEnabledNotifierProvider`). See `_InfoBanner` in `species_list_screen.dart`.

## Confirmation dialogs

Keep the native `AlertDialog` untouched — the project does not restyle dialogs, snackbars, or date pickers.

## Imports needed

```dart
import 'dart:ui'; // for ImageFilter.blur
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../settings/presentation/providers/settings_providers.dart'; // transparencyEnabledNotifierProvider
import '../../domain/<entity>_model.dart';
```

Adjust the relative depth of the settings import to the target feature folder.

## Workflow

1. Read `home_screen.dart` and `plant_list_item.dart` to confirm the reference is still current.
2. Read the target list screen to capture its business logic (`_confirmDelete`, navigation callbacks, providers, async source).
3. Rewrite the screen following the template above, preserving all business logic untouched — only the visual shell changes.
4. Extract each row into a private `_XxxListItem extends ConsumerWidget` in the same file. Do not export it to a shared widget folder — the project's convention is per-file copies.
5. Add a private `_EmptyState` in the same file.
6. Run `flutter analyze` on the changed file to confirm no warnings were introduced.

## What NOT to do

- Don't restyle the `FloatingActionButton` — keep the default Material look.
- Don't omit `transparencyEnabledNotifierProvider` in list items.
- Don't extract `_XxxListItem` or `_EmptyState` into `core/widgets/` proactively — every existing screen keeps these private.
- Don't change the screen's providers, filters, sort logic, or navigation while restyling.
- Don't restyle `AlertDialog`, `SnackBar`, or date pickers.
- Don't introduce new colors, radii, or paddings beyond what's in this skill or the reference files.
