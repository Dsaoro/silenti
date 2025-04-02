import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  // TextInputType keyboardType;

  SilentiTextField(
      {super.key,
      required this.input,
      required this.onChange,
      this.isDouble = false,
      this.maxLength = 20,
      this.readOnly = false,
      this.onSubmitted,
      this.prefixIcon,
      this.hintText = ""});

  @override
  State<SilentiTextField> createState() => _SilentiTextFieldState();
}

class _SilentiTextFieldState extends State<SilentiTextField> {
  TextEditingController controller = TextEditingController();

  List<TextInputFormatter> _getFormaters() {
    List<TextInputFormatter> rules = [];

    return rules;
  }

  InputDecoration _getFieldDecoration() {
    InputDecoration decoration = InputDecoration(
      isDense: true,
      enabled: !widget.readOnly,
      hintText: widget.hintText,
    );
    return decoration;
  }

  @override
  Widget build(BuildContext context) {
    controller.text = widget.input;
    return TextField(
      inputFormatters: _getFormaters(),
      maxLength: widget.maxLength,
      controller: controller,
      onChanged: (value) {
        widget.input = value;
        widget.onChange(value);
      },
      decoration: _getFieldDecoration(),
      onSubmitted: widget.onSubmitted,
      readOnly: widget.readOnly,
    );
  }
}
