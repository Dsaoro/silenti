import 'package:flutter/material.dart';

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
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.33,
          )
        ],
      ),
    );
    return transactionAlert;
  }
}
