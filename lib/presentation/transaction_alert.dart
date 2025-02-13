import 'package:flutter/material.dart';
import 'package:silenti/core/enums/silenti_styles.dart';

class TransactionAlert extends StatefulWidget {
  const TransactionAlert({super.key});

  @override
  State<StatefulWidget> createState() => _TransactionAlertState();
}

class _TransactionAlertState extends State<TransactionAlert> {
  @override
  Widget build(BuildContext context) {
    Container transactionAlert = Container(
      child: Column(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.33,
            child: Center(
              child: Column(
                children: [
                  Text(
                    "Transactions",
                    style: SilentiStyles.titleTextStyleDark,
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.45,
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          style: ButtonStyle(),
                          onPressed: () {},
                          child: Text("registrar"),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
    return transactionAlert;
  }
}
