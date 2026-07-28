import 'package:flutter/services.dart';

class SinglePeriodEnforcer extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text;
    // Allow only one period
    final separatorsCount = RegExp(r'[\.\,]').allMatches(newText).length;
    if (separatorsCount <= 1) {
      return newValue;
    }
    return oldValue;
  }
}
