import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:silenti/application/shared/handle_result.dart';
import 'package:silenti/application/storage/open_secure_database_use_case.dart';
import 'package:silenti/core/enums/silenti_colors.dart';
import 'package:silenti/generated/l10n.dart';
import 'package:silenti/presentation/budget_page.dart';
import 'package:silenti/presentation/assets_page.dart';
import 'package:silenti/presentation/home_page_content.dart';
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

class _HomePageState extends State<HomePage> {
  int currentPageIndex = 1;
  bool operationsUpdated = false;
  HomePageContent home = HomePageContent();
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

  @override
  void initState() {
    super.initState();
    _connectToDatabase();
  }

  @override
  Widget build(BuildContext context) {
    if (currentPageIndex == 1 && !operationsUpdated) {
      home = HomePageContent();
      operationsUpdated = true;
    } else {
      operationsUpdated = false;
    }

    // Widget home =

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
            label: "${S.current.asset}s",
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
              // label: Text('2'),
              child: Icon(Icons.paste_outlined),
            ),
            selectedIcon: Icon(
              Icons.paste_outlined,
              color: SilentiColors.white,
            ),
            label: S.current.budget,
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
