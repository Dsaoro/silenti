import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:silenti/core/enums/silenti_colors.dart';
import 'package:silenti/core/models/financial_asset.dart';
import 'package:silenti/generated/l10n.dart';
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
  late FinancialAsset editingAsset;

  @override
  void initState() {
    editingAsset = widget.asset;
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
            S.current.newAccount,
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
                  S.current.accountName,
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
                  input: editingAsset.name,
                  maxLength: 15,
                  keyboardType: TextInputType.text,
                  onChange: (value) {
                    editingAsset.name = value;
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
              S.current.accountBalance,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(8),
            alignment: Alignment.centerLeft,
            // height: 50,
            child: SilentiTextField(
              input: CurrencyFormater.convert(editingAsset.accountBalance),
              readOnly: widget.readOnly,
              onChange: (value) {
                // setState(() {
                editingAsset.accountBalance = double.parse(value);
                // });
              },
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
          ),
        ]),
      ),

      SizedBox(
        height: 8,
      ),

      ///Included on Balance
      Row(
        children: [
          ///Included on Balance checkbox
          Container(
            padding: EdgeInsets.all(8),
            width: MediaQuery.of(context).size.width * 0.1,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Checkbox(
                value: editingAsset.includedOnBalance == 1,
                onChanged: (value) {
                  if (widget.readOnly) return;
                  if (value != null && value) {
                    editingAsset.includedOnBalance = 1;
                  } else {
                    editingAsset.includedOnBalance = 0;
                  }
                  setState(() {});
                }),
          ),
          SizedBox(
            width: 8,
          ),
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
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
      SizedBox(
        height: 8,
      ),

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
                  alignment: Alignment.centerLeft,
                  child: Text(
                    S.current.frequency,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton(
                    onChanged: (value) {
                      value = value ?? 0;
                      if (kDebugMode) {
                        print(FinancialAssetFrequency.list[value]);
                      }
                      editingAsset.frequency =
                          FinancialAssetFrequency.list[value];
                    },
                    borderRadius: BorderRadius.circular(4),
                    elevation: 2,
                    alignment: Alignment.centerLeft,
                    value: 0,
                    items: FinancialAssetFrequency.listNames.map((element) {
                      return DropdownMenuItem(
                        value:
                            FinancialAssetFrequency.listNames.indexOf(element),
                        child: Text(element),
                      );
                    }).toList(),
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
            child: Column(children: [
              Container(
                padding: EdgeInsets.all(8),
                alignment: Alignment.centerLeft,
                child: Text(
                  S.current.interestRate,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(8),
                alignment: Alignment.centerLeft,
                // height: 50,
                child: SilentiTextField(
                  input: editingAsset.interest.toStringAsPrecision(3),
                  readOnly: widget.readOnly,
                  onChange: (value) {
                    if (value == "") {
                      value = "0";
                    }
                    if (value == ".") {
                      value = "0.";
                    }
                    editingAsset.interest = double.parse(value);
                  },
                  isDouble: true,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
              ),
            ]),
          ),
        ],
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
              backgroundColor: WidgetStateProperty.all(SilentiColors.secondary),
              foregroundColor: WidgetStateProperty.all(Colors.white),
            ),
            onPressed: () {
              if (editingAsset.name != "") {
                widget.onSave(editingAsset);
                Navigator.pop(context);
              }
            },
            child: Text(
              widget.buttonText,
              style: TextStyle(fontSize: 16, color: SilentiColors.dark),
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

    ///Listview End
  }
}
