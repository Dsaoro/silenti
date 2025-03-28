import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:silenti/application/financial_assets/get_financial_assets_balance_use_case.dart';
import 'package:silenti/application/operations/get_operations_use_case.dart';
import 'package:silenti/application/shared/handle_result.dart';
import 'package:silenti/application/storage/open_secure_database_use_case.dart';
import 'package:silenti/core/enums/silenti_colors.dart';
import 'package:silenti/core/enums/silenti_styles.dart';
import 'package:silenti/generated/l10n.dart';
import 'package:silenti/presentation/budget_page.dart';
import 'package:silenti/presentation/components/card_graph_item.dart';
import 'package:silenti/presentation/components/category_button.dart';
import 'package:silenti/presentation/assets_page.dart';
import 'package:silenti/presentation/components/operation_card_list_item.dart';
import 'package:silenti/presentation/components/resume_card.dart';
import 'package:silenti/presentation/components/shimmer.dart';
import 'package:silenti/presentation/components/shimmer_loading.dart'
    show ShimmerLoading;
import 'package:silenti/presentation/components/wrap_gradient_backgroud.dart';
import 'package:silenti/presentation/operation_alert.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
// import 'package:sqflite_sqlcipher/sqflite.dart';

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
  bool operationsUpdated = false;
  bool isLoading = true;
  double accountBalance = 0;
  double spendBalance = 0;
  double totalBalance = 0;
  List<Widget> lastOperations = [];
  Future<HandleResult<bool>?> registerOperation() async {
    Dialog alert = Dialog(
      // title: Text("Registrar operación"),
      child: OperationAlert(),
    );
    return await showDialog<HandleResult<bool>?>(
      context: context,
      builder: (context) {
        return alert;
      },
    );
  }

  Future<Database?> _connectToDatabase() async {
    OpenSecureDatabaseUseCase openDB = OpenSecureDatabaseUseCase();
    try {
      await Future.delayed(Duration(milliseconds: 300));
      Database db = await openDB.execute(password: "");
      setState(() {
        isLoading = false;
      });
      if (kDebugMode) {
        print("Base de datos abierta con éxito: ${db.path}");
      }
      return db;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    }
  }

  _getMonthBalance() async {
    var assetsBalance = await GetFinancialAssetsBalanceUseCase().execute();
    var spentBalance = 0.0;
    setState(() {
      if (kDebugMode) {
        print("assetBalance.model ${assetsBalance.model}");
      }
      accountBalance = assetsBalance.model;
      spendBalance = spentBalance;
      totalBalance = accountBalance - spentBalance;
    });
  }

  // String _getShowableDate(DateTime date) {
  //   String fecha = date.toIso8601String();
  //   return fecha.split("T")[0];
  // }

  _getLastOperations() async {
    var result = await GetOperations().getLastOperations(limit: 10);
    if (result.status && result.model.isNotEmpty) {
      if (kDebugMode) {
        print("read last ${result.model.length} operations");
      }
      List<Widget> operations = [];
      for (var e in result.model) {
        operations.add(OperationCardListItem(
          operation: e,
          isLoading: false,
        ));
      }
      setState(() {
        lastOperations = operations;
      });
      // setState(() {
      //   lastOperations = result.model
      //       .map((e) => OperationCardListItem(
      //             isLoading: false,
      //             title:
      //                 "${e.type}. ${e.category} - ${_getShowableDate(e.date)}",
      //             content: e.amount.toString(),
      //           ))
      //       .toList();
      // });
    } else {
      if (kDebugMode) {
        print("error retrieving last operations ${result.message}");
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _connectToDatabase();
    _getMonthBalance();
  }

  @override
  Widget build(BuildContext context) {
    if (currentPageIndex == 1 && !operationsUpdated) {
      _getLastOperations();
      operationsUpdated = true;
    } else {
      operationsUpdated = false;
    }

    Widget incomes = SizedBox(
      width: MediaQuery.of(context).size.width * 0.44,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            S.current.income,
            style: SilentiStyles.subtitleTextStyle,
          ),
          Text(
            "\$ ${accountBalance.toStringAsFixed(2)}",
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
            "\$ ${spendBalance.toStringAsFixed(2)}",
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
          S.current.balance,
          style: SilentiStyles.titleTextStyle,
        ),
        Text(
          "\$ ${totalBalance.toStringAsFixed(2)}",
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
                    //TODO check issue with Null invalid renderbox
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
        child: ShimmerLoading(
          isLoading: isLoading,
          child: Container(
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: ListView(
              children: [
                summary,
                CardGraphItem(
                  isLoading: isLoading,
                  title: S.current.sumary,
                ),
                ResumeCard(
                  isLoading: isLoading,
                  children: lastOperations,
                ),
              ],
            ),
          ),
        ),
      ),
    );

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
            label: S.current.spent,
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
        onPressed: () async {
          await registerOperation();
          await _getMonthBalance();
          operationsUpdated = false;
        },
        tooltip: S.current.income,
        child: Icon(
          Icons.add,
          color: SilentiColors.primary,
        ),
      ),
    );
  }
}
