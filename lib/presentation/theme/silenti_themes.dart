import 'package:flutter/material.dart';
import 'package:silenti/core/enums/silenti_colors.dart';

ThemeData silentiTheme() {
  return ThemeData(
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: SilentiColors.primary,
      onPrimary: SilentiColors.white,
      secondary: SilentiColors.secondary,
      onSecondary: SilentiColors.white,
      error: SilentiColors.warning,
      onError: SilentiColors.white,
      surface: SilentiColors.gray,
      onSurface: SilentiColors.dark,
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(
        fontSize: 16,
        color: Colors.black,
      ),
    ),
  );
}

ThemeData silentiDarkTheme() {
  return ThemeData(
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: SilentiColors.primary,
      onPrimary: SilentiColors.white,
      secondary: SilentiColors.secondary,
      onSecondary: SilentiColors.white,
      error: SilentiColors.warning,
      onError: SilentiColors.white,
      surface: SilentiColors.gray,
      onSurface: SilentiColors.dark,
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(
        fontSize: 16,
        color: Colors.black,
      ),
    ),
  );
}
