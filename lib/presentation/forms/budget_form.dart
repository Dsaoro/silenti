import 'package:flutter/material.dart';
import 'package:silenti/core/models/budget_category.dart';
import 'package:silenti/generated/l10n.dart';
import 'package:silenti/presentation/components/silenti_text_field.dart';
import 'package:silenti/utils/currency_formater.dart';

// ignore: must_be_immutable
class BudgetForm extends StatefulWidget {
  Function onSave;
  final BudgetCategory budget;
  final bool readOnly;
  final bool showHead;
  final bool showName;
  final bool showButton;
  String buttonText;
  BudgetForm({
    super.key,
    required this.onSave,
    required this.budget,
    this.readOnly = false,
    this.showHead = true,
    this.showName = true,
    this.showButton = true,
    required this.buttonText,
  });

  @override
  State<BudgetForm> createState() => _BudgetFormState();
}

class _BudgetFormState extends State<BudgetForm> {
  late String _name;
  late double _amount;
  late String _amountInput;

  @override
  void initState() {
    _name = widget.budget.name;
    _amount = widget.budget.amount;
    _amountInput = CurrencyFormater.convert(_amount);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    if (widget.showHead) {
      children.addAll([
        Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.all(8),
          child: Text(
            S.current.newBudget,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 16,
        ),
      ]);
    }
    if (widget.showName) {
      children.addAll([
        Container(
          padding: EdgeInsets.symmetric(vertical: 0, horizontal: 4),
          width: MediaQuery.of(context).size.width,
          alignment: Alignment.topLeft,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(4),
                alignment: Alignment.centerLeft,
                child: Text(
                  S.current.budgetName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(4),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SilentiTextField(
                  input: _name,
                  maxLength: 15,
                  keyboardType: TextInputType.text,
                  onChange: (value) {
                    setState(() {
                      _name = value;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ]);
    }
    children.addAll([
      ///Inicial Account Balance
      Container(
        padding: EdgeInsets.symmetric(vertical: 0, horizontal: 4),
        width: MediaQuery.of(context).size.width * 0.8,
        alignment: Alignment.topLeft,
        child: Column(children: [
          Container(
            padding: EdgeInsets.all(8),
            alignment: Alignment.centerLeft,
            child: Text(
              S.current.monthlyBudget,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(8),
            alignment: Alignment.centerLeft,
            child: SilentiTextField(
              input: _amountInput,
              readOnly: widget.readOnly,
              onChange: (value) {
                setState(() {
                  _amountInput = value;
                  // Handle potential parse errors if needed, though convert handles basics
                  try {
                    String sanitized = value.replaceAll(',', '.');
                    // Simple sanitization for example, careful with localization
                    _amount = double.parse(sanitized);
                  } catch (e) {
                    // ignore
                  }
                });
              },
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
          ),
        ]),
      ),
    ]);
    if (widget.showButton) {
      children.addAll([
        SizedBox(
          height: 8,
        ),
        Container(
          padding: EdgeInsets.all(8),
          alignment: Alignment.centerRight,
          child: TextButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(
                  Theme.of(context).colorScheme.secondary),
              foregroundColor: WidgetStateProperty.all(
                  Theme.of(context).colorScheme.onSurface),
            ),
            onPressed: () {
              if (_name.isNotEmpty) {
                final updatedBudget = widget.budget.copyWith(
                  name: _name,
                  amount: _amount,
                );
                widget.onSave(updatedBudget);
                Navigator.pop(context);
              }
            },
            child: Text(
              widget.buttonText,
              style: TextStyle(
                  fontSize: 16, color: Theme.of(context).colorScheme.onSurface),
            ),
          ),
        )
      ]);
    }
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 0,
        horizontal: 16,
      ),
      alignment: Alignment.center,
      child: ListView(
        children: children,
      ),
    );
  }
}
