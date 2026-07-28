import 'package:flutter/material.dart';
import 'package:silenti/core/enums/silenti_colors.dart';

ThemeData silentiTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: SilentiColors.primary,
      brightness: Brightness.light,
      // Mapeo personalizado de colores
      primary: SilentiColors.primary,
      secondary: SilentiColors.secondary,
      error: SilentiColors.warning,
      surface: SilentiColors.gray,
      onSurface: SilentiColors.dark,
      onPrimary: SilentiColors.white,
      onSecondary: SilentiColors.white,
      onError: SilentiColors.white,
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(
        fontSize: 16,
        color: SilentiColors.dark,
      ),
      titleLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: SilentiColors.dark,
      ),
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: SilentiColors.gray,
      ),
    ),
    // Configuración adicional para componentes específicos
    appBarTheme: AppBarTheme(
      foregroundColor: SilentiColors.primary,
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: SilentiColors.secondary,
        foregroundColor: SilentiColors.dark,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      indicatorColor: SilentiColors.primary,
      backgroundColor: SilentiColors.gray,
    ),
  );
}

ThemeData silentiDarkTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: SilentiColors.primary,
      brightness: Brightness.dark,
      // Mapeo para dark mode
      primary: SilentiColors.primary,
      secondary: SilentiColors.secondary,
      error: SilentiColors.warning,
      surface: const Color(0xFF1A1A1A), // Superficie más oscura
      onSurface: SilentiColors.white,
      // background: SilentiColors.dark,
      // onBackground: SilentiColors.white,
      onPrimary: SilentiColors.white,
      onSecondary: SilentiColors.dark,
      onError: SilentiColors.white,

      // Colores adicionales para mejor contraste en dark mode
      // surfaceVariant: const Color(0xFF2A2A2A),
      onSurfaceVariant: SilentiColors.gray,
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(
        fontSize: 16,
        color: SilentiColors.white,
      ),
      titleLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: SilentiColors.white,
      ),
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: SilentiColors.gray,
      ),
    ),
    // Configuración específica para dark mode
    appBarTheme: AppBarTheme(
      foregroundColor: SilentiColors.primary,
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: SilentiColors.secondary,
        foregroundColor: SilentiColors.dark,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      indicatorColor: SilentiColors.primary,
      backgroundColor: const Color(0xFF2A2A2A),
    ),
    // Configuración adicional para mejorar la experiencia en dark mode
    cardTheme: CardThemeData(
      color: const Color(0xFF2A2A2A),
      elevation: 2,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: const Color(0xFF2A2A2A),
    ),
  );
}
