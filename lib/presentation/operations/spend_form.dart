import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:silenti/application/budgets/get_expenses_categories_use_case.dart';
import 'package:silenti/application/budgets/get_expenses_sub_categories_use_Case.dart';
import 'package:silenti/application/financial_assets/get_financial_assets.dart';
import 'package:silenti/application/financial_assets/withdraw_from_financial_asset_use_case.dart';
import 'package:silenti/core/models/operation.dart';
import 'package:silenti/generated/l10n.dart';
import 'package:silenti/presentation/components/silenti_date_picker.dart';
import 'package:silenti/presentation/components/silenti_text_field.dart';
import 'package:silenti/utils/currency_formater.dart';

class SpendForm extends StatefulWidget {
  const SpendForm({super.key});

  @override
  State<SpendForm> createState() => _SpendFormState();
}

class _SpendFormState extends State<SpendForm> {
  int category = 0;
  int subCategory = 0;
  double amount = 0;
  String _amountInput = "";
  int financialAssetId = 1;
  String description = "";

  DateTime date = DateTime.now();

  bool _isLoading = true;
  final Map<int, String> _assets = {};
  // int currentSelectedIndex = 0;
  final Map<int, String> _categories = {0: S.current.select};
  Map<int, String> _subCategories = {0: S.current.select};

  void _toggleLoading() {
    setState(() {
      _isLoading = !_isLoading;
    });
  }

  _requestAssets() async {
    var response = await GetFinancialAssets().execute();
    if (response.status) {
      for (var asset in response.model) {
        _assets.addEntries([MapEntry(asset.id, asset.name)]);
      }
    } else {
      if (kDebugMode) {
        print(response.message);
      }
    }
  }

  _getCategories() async {
    var response = await GetExpensesCategoriesUseCase().execute();
    if (response.status) {
      for (var category in response.model) {
        _categories.addEntries([MapEntry(category.id, category.name)]);
      }
    }
  }

  _getSubCategories() async {
    var response = await GetExpensesSubCategoriesUseCase().byId(id: category);
    if (response.status) {
      for (var category in response.model) {
        _subCategories.addEntries([MapEntry(category.id, category.name)]);
      }
    }
  }

  _getDataFromDB() async {
    await _requestAssets();
    await _getCategories();
    await _getSubCategories();
    setState(() {
      _toggleLoading();
    });
  }

  _registerOperation() async {
    if (kDebugMode) {
      print("register amount $amount");
    }
    Operation operation = Operation(
      id: 0,
      financialAsset: financialAssetId,
      amount: amount,
      date: date,
      description: description,
      category: category,
      type: Operation.expense,
    );
    var depositResponse =
        await WithdrawFromFinancialAssetUseCase().execute(operation);
    if (!depositResponse.status) {
      //Error in deposit
      if (kDebugMode) {
        print("error in withdraw");
      }
    } else {
      if (kDebugMode) {
        print("sucess in withdraw");
      }
    }

    await Future.delayed(Duration(seconds: 2));
  }

  @override
  void initState() {
    _getDataFromDB();
    _amountInput = CurrencyFormater.convert(amount);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _subCategories = {};
    return Container(
      padding: EdgeInsets.all(16),
      width: MediaQuery.of(context).size.width * 0.8,
      child: ListView(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.all(8),
            child: Text(
              S.current.spendRegistration,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: 16,
          ),
          Container(
            padding: EdgeInsets.all(8),
            alignment: Alignment.centerLeft,
            child: Text(
              S.current.amount,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // SizedBox(
          //   height: 8,
          // ),
          Container(
            padding: EdgeInsets.all(8),
            alignment: Alignment.centerLeft,
            // height: 50,
            child: SilentiTextField(
              isMoney: true,
              input: _amountInput,
              onChange: (value) {
                setState(() {
                  _amountInput = value;
                  try {
                    String sanitized = value.replaceAll(',', '.');
                    amount = double.parse(sanitized);
                  } catch (_) {}
                });
              },
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
          ),
          SizedBox(
            height: 8,
          ),
          //Account
          Container(
            padding: EdgeInsets.all(8),
            alignment: Alignment.centerLeft,
            child: Text(
              S.current.asset,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: 8,
          ),
          Container(
            padding: EdgeInsets.all(8),
            width: MediaQuery.of(context).size.width * 0.37,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton(
              borderRadius: BorderRadius.circular(4),
              elevation: 2,
              alignment: Alignment.centerLeft,
              value: financialAssetId,
              items: _assets.entries
                  .map(
                    (entry) => DropdownMenuItem(
                      value: entry.key,
                      child: Text(entry.value),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  financialAssetId = value ?? -1;
                });
              },
            ),
          ),
          SizedBox(
            height: 8,
          ),
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 0, horizontal: 4),
                width: MediaQuery.of(context).size.width * 0.35,
                alignment: Alignment.topLeft,
                child: Column(children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      S.current.category,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Container(
                    padding: EdgeInsets.all(8),
                    width: MediaQuery.of(context).size.width * 0.37,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton(
                      borderRadius: BorderRadius.circular(4),
                      elevation: 2,
                      alignment: Alignment.centerLeft,
                      value: category,
                      items: _categories.entries
                          .map(
                            (entry) => DropdownMenuItem(
                              value: entry.key,
                              child: Text(entry.value),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          category = value ?? 0;
                        });
                      },
                    ),
                  ),
                ]),
              ),
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
                        S.current.subCategory,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    FutureBuilder(
                      future: _getSubCategories(),
                      builder: (context, snapshot) {
                        return Container(
                          padding: EdgeInsets.all(8),
                          width: MediaQuery.of(context).size.width * 0.37,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButton(
                            borderRadius: BorderRadius.circular(4),
                            elevation: 2,
                            alignment: Alignment.centerLeft,
                            value: subCategory,
                            items: _categories.entries
                                .map(
                                  (entry) => DropdownMenuItem(
                                    value: entry.key,
                                    child: Text(entry.value),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                subCategory = value ?? 0;
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              )
            ],
          ),
          SizedBox(
            height: 8,
          ),
          Container(
            padding: EdgeInsets.all(8),
            alignment: Alignment.centerLeft,
            child: Text(
              S.current.date,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: 8,
          ),

          SilentiDatePicker(
            inputDate: DateTime.now(),
            onChange: (value) {
              date = value;
              if (kDebugMode) {
                print("Selected date $date");
              }
            },
          ),
          SizedBox(
            height: 8,
          ),
          ExpansionTile(
            title: Text(
              S.current.description,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                alignment: Alignment.topCenter,
                child: SilentiTextField(
                  input: description,
                  onChange: (value) {
                    description = value;
                  },
                  keyboardType: TextInputType.text,
                  maxLines: 3,
                ),
              )
            ],
          ),
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
                _registerOperation();
                Navigator.pop(context);
              },
              child: Text(
                S.current.register,
                style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurface),
              ),
            ),
          )
        ],
      ),
    );
  }
}
