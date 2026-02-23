import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:silenti/application/financial_assets/get_total_balance_chart_data_use_case.dart';
import 'package:silenti/application/operations/get_operations_use_case.dart';

import 'package:silenti/presentation/components/operation_card_list_item.dart';
import 'package:silenti/presentation/components/resume_card.dart';
import 'package:silenti/presentation/components/shimmer.dart';
import 'package:silenti/presentation/components/shimmer_loading.dart';
import 'package:silenti/presentation/components/summary_card.dart';
import 'package:silenti/presentation/components/wrap_gradient_backgroud.dart';

class HomePageContent extends StatefulWidget {
  const HomePageContent({super.key});

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

  _getLastOperations() async {
    var result = await GetOperations().getLastOperations(limit: 10);
    if (result.status && result.model!.isNotEmpty) {
      if (kDebugMode) {
        print("read last ${result.model!.length} operations");
      }
      List<Widget> operations = [];
      for (var e in result.model!) {
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

  _loadSummaryChartData() async {
    var chartResponse =
        await GetTotalBalanceChartDataUseCase().executeForHome();

    if (chartResponse.status) {
      setState(() {
        summaryChartData = chartResponse.model!;
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

  @override
  void initState() {
    _loadSummaryChartData();
    _getLastOperations();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                SummaryCard(),
                // Container(
                //   height: MediaQuery.of(context).size.height * 0.2,
                //   child: CardGraphItem(
                //     isLoading: isLoading,
                //     title: "${S.current.summary} - Balance Evolution",
                //     chartData: summaryChartData,
                //     showGrid: true,
                //     showTitles: false,
                //   ),
                // ),
                ResumeCard(
                  isLoading: isLoading,
                  height: MediaQuery.of(context).size.height * 0.5,
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
