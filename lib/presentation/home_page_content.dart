import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:silenti/application/financial_assets/get_financial_assets_balance_use_case.dart';
import 'package:silenti/application/financial_assets/get_total_balance_chart_data_use_case.dart';
import 'package:silenti/application/operations/get_operations_use_case.dart';
import 'package:silenti/core/enums/silenti_colors.dart';
import 'package:silenti/core/enums/silenti_styles.dart';
import 'package:silenti/generated/l10n.dart';
import 'package:silenti/presentation/components/card_graph_item.dart';
import 'package:silenti/presentation/components/category_button.dart';
import 'package:silenti/presentation/components/operation_card_list_item.dart';
import 'package:silenti/presentation/components/resume_card.dart';
import 'package:silenti/presentation/components/shimmer.dart';
import 'package:silenti/presentation/components/shimmer_loading.dart';
import 'package:silenti/presentation/components/wrap_gradient_backgroud.dart';
import 'package:silenti/presentation/theme/silenti_themes.dart';
import 'package:silenti/presentation/theme/theme_extensions.dart';
import 'package:silenti/utils/currency_formater.dart';

class HomePageContent extends StatefulWidget {
  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

const _shimmerGradient = LinearGradient(
  colors: [Color(0xFFEBEBF4), Color(0xFFF4F4F4), Color(0xFFEBEBF4)],
  stops: [0.1, 0.3, 0.4],
  begin: Alignment(-1.0, -0.3),
  end: Alignment(1.0, 0.3),
  tileMode: TileMode.clamp,
);

class _HomePageContentState extends State<HomePageContent> {
  bool isLoading = false;
  double accountBalance = 0;
  double spendBalance = 0;
  double totalBalance = 0;
  List<Widget> lastOperations = [];
  List<FlSpot> summaryChartData = [];

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

  _loadSummaryChartData() async {
    var chartResponse =
        await GetTotalBalanceChartDataUseCase().executeForHome();

    if (chartResponse.status) {
      setState(() {
        summaryChartData = chartResponse.model;
      });
    } else {
      if (kDebugMode) {
        print("Error loading summary chart data: ${chartResponse.message}");
      }
      setState(() {
        summaryChartData = [];
      });
    }
  }

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
    } else {
      if (kDebugMode) {
        print("error retrieving last operations ${result.message}");
      }
    }
  }

  @override
  void initState() {
    _getMonthBalance();
    _getLastOperations();
    _loadSummaryChartData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget incomes = SizedBox(
      width: MediaQuery.of(context).size.width * 0.44,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            S.current.income,
            style: SilentiStyles.subtitleTextStyle(context),
          ),
          Text(
            "\$${CurrencyFormater.convert(accountBalance)}",
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
            S.current.spent,
            style: SilentiStyles.subtitleTextStyle(context),
          ),
          Text(
            "\$${CurrencyFormater.convert(spendBalance)}",
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
          style: SilentiStyles.titleTextStyle(context),
        ),
        Text(
          "\$${CurrencyFormater.convert(totalBalance)}",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );

    Widget sumary = Container(
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

    return Shimmer(
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
                sumary,
                CardGraphItem(
                  isLoading: isLoading,
                  title: "${S.current.sumary} - Balance Evolution",
                  chartData: summaryChartData,
                  showGrid: true,
                  showTitles: false,
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
  }
}
