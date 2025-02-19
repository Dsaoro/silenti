import 'package:flutter/material.dart';
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

  void _toggleLoading() {
    setState(() {
      _isLoading = !_isLoading;
    });
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
          _buildListItem(),
          _buildListItem(),
          _buildListItem(),
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
      height: 72,
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
    return ShimmerLoading(isLoading: _isLoading, child: const CircleListItem());
  }

  Widget _buildGraphItem() {
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
}
