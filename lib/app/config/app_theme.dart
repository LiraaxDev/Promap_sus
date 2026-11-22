import 'package:flutter/material.dart';

/// Temas com diretrizes de acessibilidade (RNF04 - WCAG 2.1 / e-MAG):
/// alto contraste (acionado pelo SO via `highContrastTheme`), áreas de toque
/// ampliadas (>= 56 dp) e respeito ao redimensionamento de fonte do sistema.
class AppTheme {
  const AppTheme._();

  static const double areaToqueMinima = 56;

  static ThemeData claro() => _base(
        ColorScheme.fromSeed(seedColor: const Color(0xFF005A9C)),
      );

  static ThemeData altoContraste() => _base(
        const ColorScheme.highContrastLight(
          primary: Color(0xFF000000),
          onPrimary: Color(0xFFFFFFFF),
        ),
      );

  static ThemeData _base(ColorScheme cs) => ThemeData(
        useMaterial3: true,
        colorScheme: cs,
        materialTapTargetSize: MaterialTapTargetSize.padded,
        visualDensity: VisualDensity.standard,
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size(areaToqueMinima, areaToqueMinima),
            textStyle: const TextStyle(fontSize: 18),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.all(16),
        ),
      );
}
