import 'package:flutter/material.dart';
import 'package:silenti/core/enums/silenti_colors.dart';
import 'package:silenti/generated/l10n.dart';
import 'package:silenti/presentation/operations/income_form.dart';
import 'package:silenti/presentation/operations/spend_form.dart';

class OperationAlert extends StatefulWidget {
  const OperationAlert({super.key});

  @override
  State<StatefulWidget> createState() => _OperationAlertState();
}

class _OperationAlertState extends State<OperationAlert> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, Widget> tabs = {
      S.current.spent: SpendForm(),
      S.current.income: IncomeForm(),
    };

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          foregroundColor: Theme.of(context).colorScheme.primary,
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
