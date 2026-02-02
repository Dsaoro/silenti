import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:silenti/application/budgets/get_expenses_categories_use_case.dart';
import 'package:silenti/application/financial_assets/deposit_in_financial_asset_use_case.dart';
import 'package:silenti/application/financial_assets/get_financial_assets.dart';
import 'package:silenti/core/models/operation.dart';
import 'package:silenti/generated/l10n.dart';
import 'package:silenti/presentation/components/silenti_date_picker.dart';
import 'package:silenti/presentation/components/single_period_enforcer.dart';

class IncomeForm extends StatefulWidget {
  const IncomeForm({super.key});

  @override
  State<IncomeForm> createState() => _IncomeFormState();
}

class _IncomeFormState extends State<IncomeForm> {
  bool _isLoading = true;
  int category = 1;
  int subCategory = 0;
  double amount = 0.0;
  int financialAssetId = 1;
  String description = "";
  DateTime date = DateTime.now();
  final Map<int, String> _categories = {};
  final Map<int, String> _assets = {};

  _registerDeposit() async {
    Operation operation = Operation(
      id: 0,
      financialAsset: financialAssetId,
      amount: amount,
      date: date,
      description: description,
      category: category,
      type: Operation.income,
    );
    //TODO make deposit into account
    var depositResponse =
        await DepositInFinancialAssetUseCase().execute(operation);
    if (!depositResponse.status) {
      //Error in deposit
      if (kDebugMode) {
        print("error in deposit");
      }
    } else {
      if (kDebugMode) {
        print("sucess in deposit");
      }
    }

    await Future.delayed(Duration(seconds: 2));
  }

  void _toggleLoading() {
    setState(() {
      _isLoading = !_isLoading;
    });
  }

  _getCategories() async {
    var response = await GetExpensesCategoriesUseCase().execute();
    if (response.status) {
      _categories.clear();
      _categories.addEntries([MapEntry(0, "Select cat...")]);
      for (var category in response.model) {
        _categories.addEntries([
          MapEntry(
              category.id,
              category.name.length > 10
                  ? "${category.name.substring(0, 10)}..."
                  : category.name)
        ]);
      }
    }
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

  _getDataFromDB() async {
    await _requestAssets();
    await _getCategories();
    setState(() {
      _toggleLoading();
    });
  }

  @override
  void initState() {
    _getDataFromDB();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 32,
        vertical: 16,
      ),
      width: MediaQuery.of(context).size.width * 0.8,
      child: ListView(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.all(8),
            child: Text(
              S.current.depositRegistration,
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
            child: TextField(
              onChanged: (value) {
                // setState(() {
                amount = double.parse(value);
                // });
              },
              controller: TextEditingController(),
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'[\d\.]')),
                SinglePeriodEnforcer()
              ],
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.left,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.attach_money),
                hintText: "1.000.000.00",
              ),
            ),
          ),
          SizedBox(
            height: 8,
          ),
          Row(children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 4),
              width: MediaQuery.of(context).size.width * 0.33,
              alignment: Alignment.topLeft,
              child: Column(children: [
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
                  width: MediaQuery.of(context).size.width * 0.33,
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
              ]),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 4),
              width: MediaQuery.of(context).size.width * 0.33,
              alignment: Alignment.topLeft,
              child: Column(
                children: [
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
                    width: MediaQuery.of(context).size.width * 0.33,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton(
                      borderRadius: BorderRadius.circular(4),
                      elevation: 2,
                      alignment: Alignment.centerLeft,
                      value: subCategory,
                      items: _categories.entries.isNotEmpty
                          ? _categories.entries
                              .map(
                                (entry) => DropdownMenuItem(
                                  value: entry.key,
                                  child: Text(entry.value),
                                ),
                              )
                              .toList()
                          : [
                              DropdownMenuItem(
                                value: 0,
                                child: Text("None"),
                              ),
                            ],
                      onChanged: (value) {
                        subCategory = value ?? 0;
                      },
                    ),
                  ),
                ],
              ),
            )
          ]),
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
                _registerDeposit();
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
