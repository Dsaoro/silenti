import 'package:flutter/material.dart';
import 'package:silenti/core/enums/silenti_colors.dart';
import 'package:silenti/generated/l10n.dart';

class OutcomePage extends StatefulWidget {
  const OutcomePage({super.key});

  @override
  State<StatefulWidget> createState() => _OutcomePageState();
}

class _OutcomePageState extends State<OutcomePage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            height: MediaQuery.of(context).size.height * 0.35,
            child: Text(S.current.outcome),
          ),
          Card(
            color: SilentiColors.gray,
            child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.52),
          )
        ],
      ),
    );
  }
}
