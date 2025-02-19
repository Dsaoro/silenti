import 'package:flutter/material.dart';
import 'package:silenti/core/enums/silenti_colors.dart';
import 'package:silenti/core/enums/silenti_styles.dart';
import 'package:silenti/generated/l10n.dart';
import 'package:silenti/presentation/budget_page.dart';
import 'package:silenti/presentation/components/card_graph_item.dart';
import 'package:silenti/presentation/components/category_button.dart';
import 'package:silenti/presentation/assets_page.dart';
import 'package:silenti/presentation/components/shimmer.dart';
import 'package:silenti/presentation/components/shimmer_loading.dart'
    show ShimmerLoading;
import 'package:silenti/presentation/components/wrap_gradient_backgroud.dart';
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

const _shimmerGradient = LinearGradient(
  colors: [Color(0xFFEBEBF4), Color(0xFFF4F4F4), Color(0xFFEBEBF4)],
  stops: [0.1, 0.3, 0.4],
  begin: Alignment(-1.0, -0.3),
  end: Alignment(1.0, 0.3),
  tileMode: TileMode.clamp,
);

class _HomePageState extends State<HomePage> {
  int currentPageIndex = 1;
  bool isLoading = true;

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
        child: SizedBox(
          height: 30,
          width: MediaQuery.of(context).size.width,
        ),
      ),
      SizedBox(
        height: 5,
      ),
      Card(
        child: SizedBox(
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
    Widget summary = Container(
      alignment: Alignment.center,
      height: 174,
      child: Column(
        children: [
          Container(
            alignment: Alignment.topCenter,
            height: 100,
            child: balance,
          ),
          SizedBox(
            height: 70,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShimmerLoading(
                    isLoading: isLoading,
                    child: CategoryButton(
                      onPressed: (() {}),
                      child: incomes,
                    )),
                SizedBox(
                  width: 16,
                ),
                ShimmerLoading(
                  isLoading: isLoading,
                  child: CategoryButton(
                    onPressed: () {},
                    child: expenses,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );

    Widget home = Shimmer(
        linearGradient: _shimmerGradient,
        child: WrapGradientBackground(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              summary,
              ShimmerLoading(
                isLoading: isLoading,
                child: CardGraphItem(isLoading: isLoading),
              ),
              SizedBox(
                height: 10,
              ),
              //  ShimmerLoading(
              //    isLoading: isLoading,
              //    child: ResumeCard(
              //      children: [
              //        Column(
              //         children: lastTransactions,
              //       ),
              //    ],
              //  ),
              //),
            ],
          ),
        ));

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
        //IncomePage(),
        AssetsPage(),
        home,
        BudgetPage(),
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
