import 'package:flutter/material.dart';
import 'package:silenti/generated/l10n.dart';

// ignore: must_be_immutable
class SilentiDatePicker extends StatefulWidget {
  Function onChange;
  DateTime inputDate;

  SilentiDatePicker({
    super.key,
    required this.inputDate,
    required this.onChange,
  });

  @override
  State<SilentiDatePicker> createState() => _SilentiDatePickerState();
}

class _SilentiDatePickerState extends State<SilentiDatePicker> {
  _selectDate() async {
    DatePickerDialog dialog = DatePickerDialog(
      firstDate: DateTime.now().subtract(Duration(days: 32)),
      lastDate: DateTime.now(),
      initialDate: widget.inputDate,
      initialEntryMode: DatePickerEntryMode.input,
      fieldLabelText: S.current.date,
      fieldHintText: S.current.date,
    );
    widget.inputDate =
        await showDialog(context: context, builder: (context) => dialog) ??
            widget.inputDate;
    setState(() {});
    widget.onChange(widget.inputDate);
  }

  String _getShowableDate(DateTime date) {
    String fecha = date.toIso8601String();
    return fecha.split("T")[0];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      child: TextField(
        controller: TextEditingController(),
        readOnly: true,
        onTap: _selectDate,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.calendar_today),
          hintText: _getShowableDate(widget.inputDate),
        ),
      ),
    );
  }
}
