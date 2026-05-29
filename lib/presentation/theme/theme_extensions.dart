import 'package:flutter/material.dart';
import 'package:silenti/core/enums/silenti_colors.dart';

// Extensión para facilitar el acceso a colores específicos de Silenti
extension SilentiColorScheme on ColorScheme {
  Color get success => SilentiColors.ok;
  Color get warning => SilentiColors.warning;
  Color get info => SilentiColors.blue;

  // Colores adicionales para compatibilidad con el sistema anterior
  Color get silentiPrimary => SilentiColors.primary;
  Color get silentiSecondary => SilentiColors.secondary;
  Color get silentiDark => SilentiColors.dark;
  Color get silentiWhite => SilentiColors.white;
  Color get silentiGray => SilentiColors.gray;
}

// Extensión para facilitar el acceso a estilos de texto específicos de Silenti
extension SilentiTextTheme on TextTheme {
  TextStyle silentiTitleLarge(BuildContext context) => TextStyle(
      color: Theme.of(context).colorScheme.onSurface,
      fontSize: 24,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.bold);

  TextStyle silentiTitleMedium(BuildContext context) => TextStyle(
      color: Theme.of(context).colorScheme.onSurface.withAlpha(170),
      fontSize: 18,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.bold);

  TextStyle silentiBodyLarge(BuildContext context) => TextStyle(
      color: Theme.of(context).colorScheme.onSurface,
      fontSize: 16,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.normal);

  TextStyle silentiButton(BuildContext context) => TextStyle(
      color: Theme.of(context).colorScheme.onSecondary,
      fontSize: 16,
      fontWeight: FontWeight.w500);
}
