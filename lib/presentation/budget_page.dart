import 'package:flutter/material.dart';
import 'package:silenti/generated/l10n.dart';
import 'components/card_graph_item.dart';
import 'components/circle_list_item.dart';
import 'components/shimmer.dart';
import 'components/shimmer_loading.dart';

class BudgetPage extends StatefulWidget {
  const BudgetPage({super.key});

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

const _shimmerGradient = LinearGradient(
  colors: [
    Color(0xFFEBEBF4),
    Color(0xFFF4F4F4),
    Color(0xFFEBEBF4),
  ],
  stops: [
    0.1,
    0.3,
    0.4,
  ],
  begin: Alignment(
    -1.0,
    -0.3,
  ),
  end: Alignment(
    1.0,
    0.3,
  ),
  tileMode: TileMode.clamp,
);

class _BudgetPageState extends State<BudgetPage> {
  bool _isLoading = true;

  // void _toggleLoading() {
  //   setState(() {
  //     _isLoading = !_isLoading;
  //   });
  // }

  Widget categoryResume() {
    Widget resume = Icon(Icons.reset_tv);
    return resume;
  }

  Widget categoryOperations() {
    Widget resume = Icon(Icons.plumbing);
    return resume;
  }

  @override
  Widget build(BuildContext context) {
    return //Scaffold(
        //body:
        Shimmer(
      linearGradient: _shimmerGradient,
      child: ListView(
        physics: _isLoading ? const NeverScrollableScrollPhysics() : null,
        children: [
          const SizedBox(height: 16),
          _buildTopRowList(),
          const SizedBox(height: 16),
          _buildGraphItem(),
          const SizedBox(height: 16),
          Container(
            height: 500,
            width: MediaQuery.of(context).size.width * 0.5,
            padding: EdgeInsets.all(3),
            child: DefaultTabController(
              length: 2,
              child: Scaffold(
                appBar: AppBar(
                  bottom: TabBar(
                    tabs: [
                      Tab(
                        child: Text(S.current.subCategory),
                      ),
                      Tab(
                        child: Text(S.current.operations),
                      )
                    ],
                  ),
                ),
                body: TabBarView(
                  children: [
                    categoryResume(),
                    categoryOperations(),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
    //floatingActionButton: FloatingActionButton(
    //  onPressed: _toggleLoading,
    //  child: Icon(_isLoading ? Icons.hourglass_full : Icons.hourglass_bottom),
    //),
    //);
  }

  Widget _buildTopRowList() {
    return SizedBox(
      height: 96,
      child: ListView(
        physics: _isLoading
            ? const NeverScrollableScrollPhysics()
            : const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        children: [
          const SizedBox(width: 16),
          _buildTopRowItem(),
          _buildTopRowItem(),
          _buildTopRowItem(),
          _buildTopRowItem(),
          _buildTopRowItem(),
          _buildTopRowItem(),
        ],
      ),
    );
  }

  Widget _buildTopRowItem() {
    return ShimmerLoading(isLoading: _isLoading, child: CircleListItem());
  }

  Widget _buildGraphItem() {
    return ShimmerLoading(
      isLoading: _isLoading,
      child: CardGraphItem(isLoading: _isLoading),
    );
  }

  // Widget _buildListItem(Operation operation) {
  //   return ShimmerLoading(
  //     isLoading: _isLoading,
  //     child: OperationCardListItem(
  //       operation: operation,
  //       isLoading: _isLoading,
  //     ),
  //   );
  // }
}
