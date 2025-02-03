import 'package:flutter/material.dart';
import 'package:silenti/core/enums/silenti_colors.dart';
import 'package:silenti/generated/l10n.dart';
import 'package:silenti/presentation/income_page.dart';
import 'package:silenti/presentation/outcome_page.dart';
import 'package:silenti/presentation/transaction_alert.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentPageIndex = 1;

  void registerTransaction() {
    AlertDialog alert = AlertDialog(
      content: TransactionAlert(),
    );
    showDialog(
      context: context,
      builder: (context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget home = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            height: MediaQuery.of(context).size.height * 0.25,
            child: Text(S.current.income),
          ),
          Card(
            color: SilentiColors.gray,
            child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.62),
          )
        ],
      ),
    );

    return Scaffold(
      backgroundColor: SilentiColors.secondary,
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: SilentiColors.primary,
        selectedIndex: currentPageIndex,
        destinations: <Widget>[
          NavigationDestination(
            icon:
                const Badge(child: Icon(Icons.account_balance_wallet_outlined)),
            selectedIcon: Icon(
              Icons.account_balance_wallet_outlined,
              color: SilentiColors.white,
            ),
            label: S.current.income,
          ),
          NavigationDestination(
            selectedIcon: Icon(
              Icons.home,
              color: SilentiColors.white,
            ),
            icon: Icon(Icons.home_outlined),
            label: S.current.home,
          ),
          NavigationDestination(
            icon: Badge(
              label: Text('2'),
              child: Icon(Icons.paste_outlined),
            ),
            selectedIcon: Icon(
              Icons.paste_outlined,
              color: SilentiColors.white,
            ),
            label: S.current.outcome,
          ),
        ],
      ),
      body: <Widget>[
        IncomePage(),
        home,
        OutcomePage(),
      ][currentPageIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: registerTransaction,
        tooltip: S.current.income_transaction,
        child: Icon(
          Icons.add,
          color: SilentiColors.primary,
        ),
      ),
    );
  }
}
