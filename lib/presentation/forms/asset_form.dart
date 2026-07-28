import 'package:flutter/material.dart';

import 'package:silenti/core/models/financial_asset.dart';
import 'package:silenti/generated/l10n.dart';
import 'package:silenti/presentation/components/silenti_dropdown.dart';
import 'package:silenti/presentation/components/silenti_text_field.dart';
import 'package:silenti/utils/currency_formater.dart';

// ignore: must_be_immutable
class AssetForm extends StatefulWidget {
  Function onSave;
  final FinancialAsset asset;
  final bool readOnly;
  final bool showHead;
  final bool showName;
  final bool showButton;
  String buttonText;
  AssetForm({
    super.key,
    required this.onSave,
    required this.asset,
    this.readOnly = false,
    this.showHead = true,
    this.showName = true,
    this.showButton = true,
    required this.buttonText,
  });

  @override
  State<AssetForm> createState() => _AssetFormState();
}

class _AssetFormState extends State<AssetForm> {
  late String _name;
  late double _balance;
  late String _balanceInput;
  late int _includedOnBalance;
  late double _interestRate;
  late String _interestRateInput;
  late Frequency _frequency;

  @override
  void initState() {
    super.initState();
    _name = widget.asset.name;
    _includedOnBalance = widget.asset.includedOnBalance;
    _frequency = widget.asset.frequency;

    // Handle subclasses
    if (widget.asset is BankAccount) {
      _balance = (widget.asset as BankAccount).balance;
      _interestRate = (widget.asset as BankAccount).interestRate;
    } else if (widget.asset is InvestmentAsset) {
      // Mapping for investment if editing in this form (though arguably needs separate form)
      _balance = (widget.asset as InvestmentAsset).currentBalance;
      _interestRate = 0.0;
    } else {
      // Default or base
      _balance = widget.asset.currentBalance;
      _interestRate = 0.0;
    }

    _balanceInput = CurrencyFormater.convert(_balance);
    _interestRateInput = _interestRate.toString();
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
            S.current.newAccount,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(height: 16),
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
                  S.current.accountName,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              alignment: Alignment.centerLeft,
              child: Text(
                S.current.accountBalance,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: EdgeInsets.all(8),
              alignment: Alignment.centerLeft,
              // height: 50,
              child: SilentiTextField(
                input: _balanceInput,
                readOnly: widget.readOnly,
                onChange: (value) {
                  setState(() {
                    _balanceInput = value;
                    try {
                      String sanitized = value.replaceAll(',', '.');
                      _balance = double.parse(sanitized);
                    } catch (e) {
                      // ignore
                    }
                  });
                },
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
            ),
          ],
        ),
      ),

      SizedBox(height: 8),

      ///Included on Balance
      Row(
        children: [
          ///Included on Balance checkbox
          Container(
            padding: EdgeInsets.all(8),
            width: MediaQuery.of(context).size.width * 0.1,
            alignment: Alignment.center,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
            child: Checkbox(
              value: _includedOnBalance == 1,
              onChanged: (value) {
                if (widget.readOnly) return;
                setState(() {
                  _includedOnBalance = (value != null && value) ? 1 : 0;
                });
              },
            ),
          ),
          SizedBox(width: 8),
          //included on balance label
          Container(
            padding: EdgeInsets.symmetric(vertical: 0, horizontal: 4),
            width: MediaQuery.of(context).size.width * 0.60,
            alignment: Alignment.topLeft,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    S.current.balanceIncluded,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      SizedBox(height: 8),

      ///interest and payments frecuency
      Row(
        children: [
          ///frecuency select button
          Container(
            padding: EdgeInsets.symmetric(vertical: 0, horizontal: 4),
            width: MediaQuery.of(context).size.width * 0.35,
            alignment: Alignment.topLeft,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  alignment: Alignment.topLeft,
                  child: Text(
                    S.current.frequency,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  alignment: Alignment.topLeft,
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SilentiDropdown(
                    items: Frequency.values.map((e) => e.label).toList(),
                    input: Frequency.values.indexOf(_frequency),
                    onChanged: (value) {
                      setState(() {
                        _frequency = Frequency.values[value];
                      });
                    },
                    readOnly: widget.readOnly,
                  ),
                ),
              ],
            ),
          ),

          ///Interest Field
          Container(
            padding: EdgeInsets.symmetric(vertical: 0, horizontal: 4),
            width: MediaQuery.of(context).size.width * 0.38,
            alignment: Alignment.topLeft,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  alignment: Alignment.topLeft,
                  child: Text(
                    S.current.interestRate,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(8),
                  alignment: Alignment.topLeft,
                  height: 60,
                  // height: 50,
                  child: SilentiTextField(
                    input: _interestRateInput,
                    readOnly: widget.readOnly,
                    onChange: (value) {
                      setState(() {
                        _interestRateInput = value;
                        if (value == "") value = "0";
                        if (value == ".") value = "0.";
                        try {
                          _interestRate = double.parse(value);
                        } catch (_) {}
                      });
                    },
                    isDouble: true,
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ]);
    if (widget.showButton) {
      children.addAll([
        SizedBox(height: 8),
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
                // Construct new BankAccount (default for this form)
                final newAsset = BankAccount(
                  id: widget.asset.id,
                  name: _name,
                  includedOnBalance: _includedOnBalance,
                  frequency: _frequency,
                  balance: _balance,
                  interestRate: _interestRate,
                );
                widget.onSave(newAsset);
              }
            },
            child: Text(
              widget.buttonText,
              style: TextStyle(
                  fontSize: 16, color: Theme.of(context).colorScheme.onSurface),
            ),
          ),
        ),
      ]);
    }
    return Container(
      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
      alignment: Alignment.center,
      child: ListView(children: children),
    );
  }
}
