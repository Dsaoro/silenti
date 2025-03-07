import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:silenti/core/enums/silenti_colors.dart';
import 'package:silenti/core/enums/silenti_styles.dart';

class OperationAlert extends StatefulWidget {
  const OperationAlert({super.key});

  @override
  State<StatefulWidget> createState() => _OperationAlertState();
}

class _OperationAlertState extends State<OperationAlert> {
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
    await Future.delayed(Duration(seconds: 2));
  }

  @override
  Widget build(BuildContext context) {
    Container OperationAlert = Container(
      padding: EdgeInsets.all(16),
      width: MediaQuery.of(context).size.width * 0.8,
      child: ListView(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.all(8),
            child: Text(
              "Registrar transacción",
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
              keyboardType: TextInputType.number,
              textAlign: TextAlign.left,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.attach_money),
                hintText: "1.000.000.00",
                // border: OutlineInputBorder(
                //   borderRadius: BorderRadius.circular(8),
                // ),
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
    return OperationAlert;
  }
}
