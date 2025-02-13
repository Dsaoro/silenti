import 'package:flutter/material.dart';
import 'package:silenti/core/enums/silenti_colors.dart';

class SilentiStyles {
  static final TextStyle subtitleTextStyle = TextStyle(
      color: SilentiColors.gray,
      fontSize: 18,
      fontStyle: FontStyle.values[0],
      fontWeight: FontWeight.bold);

  static final TextStyle titleTextStyle = TextStyle(
      color: SilentiColors.gray,
      fontSize: 24,
      fontStyle: FontStyle.values[0],
      fontWeight: FontWeight.bold);
  static final TextStyle titleTextStyleDark = TextStyle(
      color: SilentiColors.dark,
      fontSize: 24,
      fontStyle: FontStyle.values[0],
      fontWeight: FontWeight.bold);
}
