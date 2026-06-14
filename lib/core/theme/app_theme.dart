import 'package:flutter/material.dart';
import 'smooth_page_transitions_builder.dart';

class AppTheme {
  AppTheme._();

  static const _seed = Color(0xFF4CAF50);

  static final _pageTransitionsTheme = PageTransitionsTheme(
    builders: {
      TargetPlatform.android: const SmoothPageTransitionsBuilder(),
      TargetPlatform.iOS: const SmoothPageTransitionsBuilder(),
      TargetPlatform.linux: const DesktopPageTransitionsBuilder(),
      TargetPlatform.macOS: const DesktopPageTransitionsBuilder(),
      TargetPlatform.windows: const DesktopPageTransitionsBuilder(),
    },
  );

  static final light = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: _seed),
    pageTransitionsTheme: _pageTransitionsTheme,
  );

  static final dark = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.dark,
    ),
    pageTransitionsTheme: _pageTransitionsTheme,
  );
}
