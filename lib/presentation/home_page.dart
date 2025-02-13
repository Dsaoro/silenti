import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:silenti/core/enums/silenti_colors.dart';
import 'package:silenti/core/enums/silenti_styles.dart';
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
    //incomes
    List<Widget> lastTransactions = [
      Card(
        child: Container(
          height: 30,
          width: MediaQuery.of(context).size.width,
        ),
      ),
      SizedBox(
        height: 5,
      ),
      Card(
        child: Container(
          height: 30,
          width: MediaQuery.of(context).size.width,
        ),
      ),
      SizedBox(
        height: 5,
      ),
    ];
    Widget incomes = SizedBox(
      width: MediaQuery.of(context).size.width * 0.44,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Income",
            style: SilentiStyles.subtitleTextStyle,
          ),
          Text(
            "\$ 100.000,00",
            style: TextStyle(
              color: SilentiColors.ok,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
    //expenses
    Widget expenses = SizedBox(
      width: MediaQuery.of(context).size.width * 0.44,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Expenses",
            style: SilentiStyles.subtitleTextStyle,
          ),
          Text(
            "\$ 0,00",
            style: TextStyle(
              color: SilentiColors.warning,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
    //balance
    Widget balance = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Balance",
          style: SilentiStyles.titleTextStyle,
        ),
        Text(
          "\$ 100.000,00",
          style: TextStyle(
            color: SilentiColors.gray,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
    Widget home = Stack(children: [
      Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            stops: [
              0.1,
              0.7,
            ],
            colors: [
              SilentiColors.primary,
              SilentiColors.dark,
            ],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
      ),
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              height: MediaQuery.of(context).size.height * 0.25,
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.25 * 0.6,
                    child: balance,
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.25 * 0.4,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {},
                          child: incomes,
                        ),
                        TextButton(
                          onPressed: () {},
                          child: expenses,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Card(
              color: SilentiColors.gray,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.62,
                child: Column(
                  //TODO add a list view
                  children: [
                    Card(
                      color: SilentiColors.gray,
                      child: Container(
                        height: 200,
                        width: MediaQuery.of(context).size.width,
                        child: LineChart(
                          LineChartData(
                            titlesData: FlTitlesData(show: false),
                            borderData: FlBorderData(show: false),
                            gridData: FlGridData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                preventCurveOverShooting: true,
                                spots: [
                                  FlSpot(0, 1),
                                  FlSpot(1, 3),
                                  FlSpot(2, 2),
                                  FlSpot(3, 4),
                                  FlSpot(4, 3.5),
                                ],
                                isCurved: true,
                                // colors: [Colors.blueAccent],
                                color: SilentiColors.secondary,
                                dotData: FlDotData(show: false),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    ListView(
                      children: lastTransactions,
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      )
    ]);

    return Scaffold(
      backgroundColor: SilentiColors.dark,
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
