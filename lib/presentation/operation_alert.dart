import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:silenti/application/transactions/save_operation_use_case.dart';
import 'package:silenti/core/enums/silenti_colors.dart';
import 'package:silenti/core/enums/silenti_styles.dart';
import 'package:silenti/core/models/operation.dart';
import 'package:silenti/presentation/components/single_period_enforcer.dart';

class OperationAlert extends StatefulWidget {
  const OperationAlert({super.key});

  @override
  State<StatefulWidget> createState() => _OperationAlertState();
}

class _OperationAlertState extends State<OperationAlert> {
  List<String> typeOptions = ["select", "spend", "income"];

  String category = "";
  String subCategory = "";
  double amount = 0.0;
  int financialAssetId = -1;
  String description = "";
  String type = "spend";
  DateTime date = DateTime.now();

  final Map<int, String> _categories = {
    0: "Gasto",
    1: "Comida",
    2: "Transporte",
    3: "Entretenimiento",
    4: "Salud",
    5: "Educación",
    6: "Otros",
  };
  _registerOperation() async {
    Operation operation = Operation(
        id: 0,
        financialAsset: financialAssetId,
        amount: amount,
        date: date,
        description: description,
        category: category,
        type: type);
    var response = await SaveOperationUSeCase().execute(operation: operation);
    if (kDebugMode) {
      print(response);
    }
    await Future.delayed(Duration(seconds: 2));
  }

  String _getShowableDate(DateTime date) {
    String fecha = date.toIso8601String();
    return fecha.split("T")[0];
  }

  _selectDate() async {
    DatePickerDialog dialog = DatePickerDialog(
      firstDate: date.subtract(Duration(days: 32)),
      lastDate: date,
      initialDate: date,
      initialEntryMode: DatePickerEntryMode.input,
      fieldLabelText: "Fecha",
      fieldHintText: "Fecha",
    );
    date = await showDialog(context: context, builder: (context) => dialog) ??
        date;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Container spendTab = Container(
      padding: EdgeInsets.all(16),
      width: MediaQuery.of(context).size.width * 0.8,
      child: ListView(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.all(8),
            child: Text(
              "Registrar Gasto",
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
              "Monto",
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
          Container(
            padding: EdgeInsets.all(8),
            alignment: Alignment.centerLeft,
            child: Text(
              "Categoria",
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
          SizedBox(
            height: 8,
          ),
          Container(
            padding: EdgeInsets.all(8),
            alignment: Alignment.centerLeft,
            child: Text(
              "Sub-categoria",
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
          SizedBox(
            height: 8,
          ),
          // Container(
          //   padding: EdgeInsets.all(8),
          //   alignment: Alignment.centerLeft,
          //   child: Text(
          //     "Fecha",
          //     style: TextStyle(
          //       fontSize: 16,
          //       fontWeight: FontWeight.bold,
          //     ),
          //   ),
          // ),
          // SizedBox(
          //   height: 8,
          // ),
          Container(
            padding: EdgeInsets.all(8),
            child: TextField(
              controller: TextEditingController(),
              readOnly: true,
              onTap: _selectDate,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.calendar_today),
                hintText: _getShowableDate(date),
              ),
            ),
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
                _registerOperation();
                Navigator.pop(context);
              },
              child: Text(
                "Registrar",
                style: TextStyle(fontSize: 16, color: SilentiColors.dark),
              ),
            ),
          )
        ],
      ),
    );

    Container incomeTab = Container(
      padding: EdgeInsets.all(16),
      width: MediaQuery.of(context).size.width * 0.8,
      child: ListView(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.all(8),
            child: Text(
              "Registrar Pago",
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
              "Monto",
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
          Container(
            padding: EdgeInsets.all(8),
            alignment: Alignment.centerLeft,
            child: Text(
              "Cuenta",
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

          SizedBox(
            height: 8,
          ),

          Container(
            padding: EdgeInsets.all(8),
            child: TextField(
              controller: TextEditingController(),
              readOnly: true,
              onTap: _selectDate,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.calendar_today),
                hintText: _getShowableDate(date),
              ),
            ),
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
                _registerOperation();
                Navigator.pop(context);
              },
              child: Text(
                "Registrar",
                style: TextStyle(fontSize: 16, color: SilentiColors.dark),
              ),
            ),
          )
        ],
      ),
    );
    Map<String, Widget> tabs = {
      "Gasto": spendTab,
      "Ingreso": incomeTab,
    };

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          foregroundColor: SilentiColors.primary,
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.payments_rounded), text: tabs.keys.first),
              Tab(icon: Icon(Icons.wallet), text: tabs.keys.last),
            ],
          ),
        ),
        body: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.9,
          alignment: Alignment.center,
          child: TabBarView(
            children: tabs.values.toList(),
          ),
        ),
      ),
    );
  }
}
