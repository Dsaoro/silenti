import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:silenti/application/budgets/get_expenses_categories_use_case.dart';
import 'package:silenti/application/financial_assets/get_financial_assets.dart';
import 'package:silenti/core/enums/silenti_colors.dart';
import 'package:silenti/core/models/financial_asset.dart';
import 'package:silenti/generated/l10n.dart';
import 'package:silenti/infraestructure/storage/financial_assets_dao.dart';
import 'package:silenti/presentation/components/single_period_enforcer.dart';

class NewAssetForm extends StatefulWidget {
  const NewAssetForm({super.key});

  @override
  State<NewAssetForm> createState() => _NewAssetFormState();
}

class _NewAssetFormState extends State<NewAssetForm> {
  bool _isLoading = true;

  double initialBalance = 0.0;
  int financialAssetId = 1;
  String frecuency = "";
  String name = "";
  int includedOnBalance = 0;
  double interestRate = 0.0;
  final Map<int, String> _categories = {};
  final Map<int, String> _assets = {};

  _createNewAsset() async {
    FinancialAsset asset = FinancialAsset(
      0,
      name,
      initialBalance,
      includedOnBalance,
      interestRate,
      frecuency,
    );

    FinancialAssetsDao dao = FinancialAssetsDao();

    dao.insertAccount(asset.toMap());
    //TODO save log for Asset Creation

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
      for (var category in response.model) {
        _categories.addEntries([MapEntry(category.id, category.name)]);
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
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(16),
        width: MediaQuery.of(context).size.width,
        child: ListView(
          children: [
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
            Container(
              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 4),
              width: MediaQuery.of(context).size.width,
              alignment: Alignment.topLeft,
              child: Column(children: [
                Container(
                  padding: EdgeInsets.all(8),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    S.current.accountName,
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
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField()),
              ]),
            ),
            SizedBox(
              height: 8,
            ),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 0, horizontal: 4),
                  width: MediaQuery.of(context).size.width * 0.55,
                  alignment: Alignment.topLeft,
                  child: Column(children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        S.current.initialAmount,
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
                      child: TextField(
                        onChanged: (value) {
                          // setState(() {
                          initialBalance = double.parse(value);
                          // });
                        },
                        controller: TextEditingController(),
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[\d\.]'),
                          ),
                          SinglePeriodEnforcer()
                        ],
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        textAlign: TextAlign.left,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.attach_money),
                          hintText: "1.000.000.00",
                        ),
                      ),
                    ),
                  ]),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 0, horizontal: 4),
                  width: MediaQuery.of(context).size.width * 0.25,
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
                      SizedBox(
                        height: 8,
                      ),
                      Container(
                        padding: EdgeInsets.all(8),
                        width: MediaQuery.of(context).size.width * 0.25,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Checkbox(
                            value: includedOnBalance == 1,
                            onChanged: (value) {
                              if (value != null && value) {
                                includedOnBalance = 1;
                              } else {
                                includedOnBalance = 0;
                              }
                              setState(() {});
                            }),
                      ),
                    ],
                  ),
                )
              ],
            ),
            SizedBox(
              height: 8,
            ),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 0, horizontal: 4),
                  width: MediaQuery.of(context).size.width * 0.55,
                  alignment: Alignment.topLeft,
                  child: Column(children: [
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
                    SizedBox(
                      height: 8,
                    ),
                    Container(
                      padding: EdgeInsets.all(8),
                      width: MediaQuery.of(context).size.width * 0.55,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButton(
                        borderRadius: BorderRadius.circular(4),
                        elevation: 2,
                        alignment: Alignment.centerLeft,
                        value: 0,
                        items: _categories.entries
                            .map(
                              (entry) => DropdownMenuItem(
                                value: entry.key,
                                child: Text(entry.value),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {},
                      ),
                    ),
                  ]),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 0, horizontal: 4),
                  width: MediaQuery.of(context).size.width * 0.25,
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
                    SizedBox(
                      height: 8,
                    ),
                    Container(
                        padding: EdgeInsets.all(8),
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField()),
                  ]),
                ),
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
                  backgroundColor:
                      WidgetStateProperty.all(SilentiColors.secondary),
                  foregroundColor: WidgetStateProperty.all(Colors.white),
                ),
                onPressed: () {
                  _createNewAsset();
                  Navigator.pop(context);
                },
                child: Text(
                  S.current.register,
                  style: TextStyle(fontSize: 16, color: SilentiColors.dark),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
