import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:silenti/application/financial_assets/get_financial_assets.dart';
import 'package:silenti/application/transactions/get_operations_use_case.dart';
import 'package:silenti/core/models/financial_asset.dart';
import 'package:silenti/core/models/operation.dart';
import 'package:silenti/presentation/components/resume_card.dart';
import 'components/card_graph_item.dart';
import 'components/notification_card_list_item.dart';
import 'components/circle_list_item.dart';
import 'components/shimmer.dart';
import 'components/shimmer_loading.dart';

class AssetsPage extends StatefulWidget {
  const AssetsPage({super.key});

  @override
  State<AssetsPage> createState() => _AssetsPageState();
}

const _shimmerGradient = LinearGradient(
  colors: [Color(0xFFEBEBF4), Color(0xFFF4F4F4), Color(0xFFEBEBF4)],
  stops: [0.1, 0.3, 0.4],
  begin: Alignment(-1.0, -0.3),
  end: Alignment(1.0, 0.3),
  tileMode: TileMode.clamp,
);

class _AssetsPageState extends State<AssetsPage> {
  bool _isLoading = true;
  List<FinancialAsset> assets = [];
  List<Operation> operations = [];
  int currentSelectedIndex = 0;

  void _toggleLoading() {
    setState(() {
      _isLoading = !_isLoading;
    });
  }

  _getDataFromDB() async {
    await _requestAssets();
    if (assets.isNotEmpty) {
      await _requestAssetOperations(currentSelectedIndex);
    }
    setState(() {
      _toggleLoading();
    });
  }

  _requestAssets() async {
    var response = await GetFinancialAssets().execute();
    if (!response.status) {
    } else {
      assets = response.model;
    }
  }

  _requestAssetOperations(int assetId) async {
    var response =
        await GetOperations().byFinancialAssetLimited(assetId, limit: 6);
    if (!response.status) {
    } else {
      setState(() {
        _toggleLoading();
        operations = response.model;
      });
    }
  }

  @override
  void initState() {
    _getDataFromDB();
    super.initState();
  }

  Widget _buildTopRowList(List<FinancialAsset> assets) {
    List<Widget> children = [
      const SizedBox(width: 16),
    ];
    if (kDebugMode) {
      print("build top row list  ${assets.isNotEmpty}");
    }
    if (assets.isNotEmpty) {
      for (var asset in assets) {
        if (kDebugMode) {
          print(" get asset ${asset.name}");
        }
        children.add(_buildTopRowItem());
      }
    }
    return SizedBox(
      height: 72,
      child: ListView(
        physics: _isLoading
            ? const NeverScrollableScrollPhysics()
            : const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        children: children,
      ),
    );
  }

  Widget _buildTopRowItem() {
    return ShimmerLoading(isLoading: _isLoading, child: const CircleListItem());
  }

  Widget _buildGraphItem() {
    if (assets.isNotEmpty) {
      return ShimmerLoading(
        isLoading: _isLoading,
        child: CardGraphItem(
          isLoading: _isLoading,
          title: assets[currentSelectedIndex].name,
        ),
      );
    }
    return ShimmerLoading(
      isLoading: _isLoading,
      child: CardGraphItem(isLoading: _isLoading),
    );
  }

  Widget _buildListItem() {
    return ShimmerLoading(
      isLoading: _isLoading,
      child: NotificationCardListItem(isLoading: _isLoading),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> operationsResume = [];
    for (var operation in operations) {
      operationsResume.add(_buildListItem());
    }
    List<Widget> children = [
      SizedBox(height: 16),
      _buildTopRowList(assets),
      const SizedBox(height: 16),
      _buildGraphItem(),
      const SizedBox(height: 8),
      ResumeCard(isLoading: _isLoading, children: [_buildListItem()])
    ];
    return //Scaffold(
        //body:
        Shimmer(
      linearGradient: _shimmerGradient,
      child: ListView(
        physics: _isLoading ? const NeverScrollableScrollPhysics() : null,
        children: children,
      ),
    );
  }
}
