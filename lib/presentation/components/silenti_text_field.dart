import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:silenti/presentation/components/single_period_enforcer.dart';
import 'package:silenti/utils/currency_formater.dart';

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
    switch (widget.keyboardType) {
      case TextInputType.number:
        isNumeric = true;
        if (widget.isDouble) {
          break;
        }
        rules = [
          FilteringTextInputFormatter.allow(RegExp(r'[\d\.]')),
          SinglePeriodEnforcer()
        ];
        break;
      default:
        break;
    }
    inputFormaters = rules;
  }

  InputDecoration _getFieldDecoration() {
    InputDecoration decoration = InputDecoration(
        isDense: true,
        isCollapsed: true,
        enabled: !widget.readOnly,
        hintText: widget.hintText,
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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    controller.text = widget.input;

    return TextField(
      inputFormatters: inputFormaters,
      maxLength: widget.maxLength,
      controller: controller,
      onChanged: (value) {
        if (isNumeric && value == "") {
          value = "0";
        }
        if (isNumeric && value == ".") {
          value = "0.";
        }
        if (isNumeric) {
          widget.input = widget.isDouble
              ? CurrencyFormater.convert(double.parse(value))
              : CurrencyFormater.convert(int.parse(value));
        } else {
          widget.input = value;
        }
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
