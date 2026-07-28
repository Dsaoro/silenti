import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:silenti/presentation/components/single_period_enforcer.dart';

// ignore: must_be_immutable
class SilentiTextField extends StatefulWidget {
  String input;
  final Function onChange;
  final Function(String)? onSubmitted;
  bool isDouble;
  int maxLength;
  bool readOnly;
  Icon? prefixIcon;
  String hintText;
  int? maxLines;
  bool isMoney;
  TextInputType keyboardType;

  SilentiTextField(
      {super.key,
      required this.input,
      required this.onChange,
      required this.keyboardType,
      this.isDouble = false,
      this.maxLength = 20,
      this.readOnly = false,
      this.onSubmitted,
      this.prefixIcon,
      this.hintText = "",
      this.isMoney = false,
      this.maxLines});

  @override
  State<SilentiTextField> createState() => _SilentiTextFieldState();
}

class _SilentiTextFieldState extends State<SilentiTextField> {
  TextEditingController controller = TextEditingController();
  late TextInputType keyboardType;
  List<TextInputFormatter> inputFormaters = [];
  bool isNumeric = false;

  void _setFormaters() {
    List<TextInputFormatter> rules = [];
    final isNumericType = widget.keyboardType.toString().contains('number');

    if (isNumericType) {
      isNumeric = true;
      if (!widget.isDouble) {
        rules = [
          FilteringTextInputFormatter.allow(RegExp(r'[\d\.\,]')),
          SinglePeriodEnforcer()
        ];
      }
    }
    inputFormaters = rules;
  }

  InputDecoration _getFieldDecoration() {
    InputDecoration decoration = InputDecoration(
        isDense: true,
        isCollapsed: true,
        enabled: !widget.readOnly,
        hintText: widget.hintText,
        counterText: "",
        prefixIcon: widget.prefixIcon);
    return decoration;
  }

  @override
  void initState() {
    isNumeric = widget.isDouble ? true : isNumeric;
    _setFormaters();
    if (widget.keyboardType == TextInputType.number && widget.isDouble) {
      keyboardType = TextInputType.numberWithOptions(decimal: true);
    } else {
      keyboardType = widget.keyboardType;
    }
    controller.text = widget.input;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant SilentiTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.input != oldWidget.input && widget.input != controller.text) {
      controller.text = widget.input;
      // Note: This might still jump cursors if an external sync happens,
      // but it prevents jumps from typing.
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      inputFormatters: inputFormaters,
      maxLength: widget.maxLength,
      controller: controller,
      onChanged: (value) {
        if (isNumeric) {
          // Normalize commas to dots for calculations
          value = value.replaceAll(',', '.');

          if (value == ".") {
            value = "0.";
          }
          // Allow empty string while typing so user can clear and start fresh
        }
        widget.input = value;
        widget.onChange(value);
      },
      textAlign: TextAlign.left,
      autofocus: true,
      keyboardType: keyboardType,
      decoration: _getFieldDecoration(),
      onSubmitted: widget.onSubmitted,
      readOnly: widget.readOnly,
      maxLines: widget.maxLines,
    );
  }
}
