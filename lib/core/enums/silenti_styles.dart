import 'package:flutter/material.dart';

class SilentiStyles {
  // Métodos estáticos que requieren contexto para obtener colores del tema
  static TextStyle subtitleTextStyle(BuildContext context) => TextStyle(
      color: Theme.of(context).colorScheme.onSurface.withAlpha(170),
      fontSize: 18,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.bold);

  static TextStyle titleTextStyle(BuildContext context) => TextStyle(
      color: Theme.of(context).colorScheme.onSurface.withAlpha(170),
      fontSize: 24,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.bold);

  static TextStyle titleTextStyleDark(BuildContext context) => TextStyle(
      color: Theme.of(context).colorScheme.onSurface,
      fontSize: 24,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.bold);

  // Métodos adicionales para otros estilos comunes
  static TextStyle bodyTextStyle(BuildContext context) => TextStyle(
      color: Theme.of(context).colorScheme.onSurface,
      fontSize: 16,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.normal);

  static TextStyle buttonTextStyle(BuildContext context) => TextStyle(
      color: Theme.of(context).colorScheme.onSecondary,
      fontSize: 16,
      fontWeight: FontWeight.w500);
}
