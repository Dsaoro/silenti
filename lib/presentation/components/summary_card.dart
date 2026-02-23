import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:silenti/application/financial_assets/get_financial_assets_balance_use_case.dart';
import 'package:silenti/application/spends/get_spends_this_month_use_case.dart';
import 'package:silenti/core/enums/silenti_colors.dart';
import 'package:silenti/core/enums/silenti_styles.dart';
import 'package:silenti/generated/l10n.dart';
import 'package:silenti/presentation/components/category_button.dart';
import 'package:silenti/presentation/components/shimmer_loading.dart';
import 'package:silenti/utils/currency_formater.dart';

class SummaryCard extends StatefulWidget {
  const SummaryCard({super.key});

  @override
  State<SummaryCard> createState() => _SummaryCardState();
}

class _SummaryCardState extends State<SummaryCard> {
  bool isLoading = true;
  double accountBalance = 0;
  double monthExpenses = 0;
  double monthIncomes = 0;

  _getMonthBalance() async {
    var assetsBalance = await GetFinancialAssetsBalanceUseCase().execute();
    var spentBalance = await GetSpendsThisMonthUseCase().execute();
    setState(() {
      if (kDebugMode) {
        print("assetBalance.model ${assetsBalance.model}");
      }
      accountBalance = assetsBalance.model;
      monthExpenses = spentBalance.model;
      accountBalance = accountBalance;
      isLoading = !isLoading;
    });
  }

  @override
  initState() {
    _getMonthBalance();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //balance
    // Widget balance = Column(
    //   mainAxisAlignment: MainAxisAlignment.center,
    //   children: [
    //     Text(
    //       S.current.balance,
    //       style: SilentiStyles.titleTextStyle(context),
    //     ),
    //     Text(
    //       "\$${CurrencyFormater.convert(accountBalance)}",
    //       style: TextStyle(
    //         color: Theme.of(context).colorScheme.onSurface.withAlpha(200),
    //         fontSize: 22,
    //         fontWeight: FontWeight.bold,
    //       ),
    //     ),
    //   ],
    // );

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
            "\$${CurrencyFormater.convert(monthExpenses)}",
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );

    return Container(
      alignment: Alignment.center,
      height: MediaQuery.of(context).size.height * 0.2,
      child: Column(
        children: [
          // Container(
          //   alignment: Alignment.topCenter,
          //   height: MediaQuery.of(context).size.height * 0.1,
          //   child: balance,
          // ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShimmerLoading(
                  //TODO check issue with Null invalid renderbox
                  isLoading: isLoading,
                  child: CategoryButton(
                    onPressed: (() {}),
                    child: incomes,
                  ),
                ),
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
  }
}
