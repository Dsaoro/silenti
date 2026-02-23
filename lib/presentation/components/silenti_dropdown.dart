import 'package:flutter/material.dart';
import 'package:silenti/generated/l10n.dart';

// ignore: must_be_immutable
class SilentiDropdown extends StatefulWidget {
  final List<String> items;
  int input;
  final Function onChanged;
  final bool readOnly;

  SilentiDropdown({
    super.key,
    required this.items,
    required this.input,
    required this.onChanged,
    this.readOnly = false,
  });

  @override
  State<SilentiDropdown> createState() => _SilentiDropdownState();
}

class _SilentiDropdownState extends State<SilentiDropdown> {
  List<String> items = [];
  @override
  initState() {
    items.add(S.current.select);
    items.addAll(widget.items);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField(
      onChanged: (value) {
        value = value ?? 0;
        widget.onChanged(value);
      },
      borderRadius: BorderRadius.circular(4),
      elevation: 2,
      alignment: Alignment.centerLeft,
      initialValue: widget.input,
      validator: (value) {
        if (value == null) {
          return widget.items.first;
        }
        return items[value];
      },
      items: widget.items.map((String item) {
        return DropdownMenuItem(
          enabled: (!widget.readOnly && item != items.first),
          value: widget.items.indexOf(item),
          child: Text(
            item,
            style: TextStyle(
              fontSize: 14,
              color: widget.readOnly
                  ? Theme.of(context).colorScheme.onSurface.withAlpha(160)
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ),
        );
      }).toList(),
    );
  }
}
