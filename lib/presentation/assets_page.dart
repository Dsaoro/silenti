import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:silenti/application/financial_assets/get_financial_assets.dart';
import 'package:silenti/application/operations/get_operations_use_case.dart';
import 'package:silenti/core/enums/silenti_colors.dart';
import 'package:silenti/core/models/financial_asset.dart';
import 'package:silenti/core/models/operation.dart';
import 'package:silenti/generated/l10n.dart';
import 'package:silenti/presentation/assets/new_asset_form.dart';
import 'components/card_graph_item.dart';
import 'components/operation_card_list_item.dart';
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
  bool _isEditing = false;
  List<FinancialAsset> assets = [];
  List<Operation> operations = [];
  int currentSelectedIndex = 1;

  void _toggleLoading() {
    setState(() {
      // _isLoading = !_isLoading;
      _isLoading = false;
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
        children.add(
          _buildTopRowItem(Icons.attach_money, asset.name, () {
            setState(() {
              currentSelectedIndex = asset.id;
            });
          }, currentSelectedIndex == asset.id),
        );
      }
    }
    children.add(
      _buildTopRowItem(Icons.add, S.current.add, () {
        Dialog alert = Dialog(
          child: NewAssetForm(),
        );
        showDialog(
          context: context,
          builder: (context) {
            return alert;
          },
        );
      }, false),
    );
    return SizedBox(
      height: 96,
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

  Widget _buildTopRowItem(
      IconData icon, String title, Function onTap, bool isSelected) {
    return ShimmerLoading(
      isLoading: _isLoading,
      child: CircleListItem(
        // onTap: () {
        //   if (kDebugMode) {
        //     print("click on item");
        //   }
        // },
        onTap: onTap,
        icon: icon,
        title: title,
        isSelected: isSelected,
      ),
    );
  }

  Widget _buildGraphItem() {
    if (assets.isNotEmpty) {
      return ShimmerLoading(
        isLoading: _isLoading,
        child: CardGraphItem(
          isLoading: _isLoading,
          title:
              assets[currentSelectedIndex <= 0 ? 0 : currentSelectedIndex - 1]
                  .name,
        ),
      );
    }
    return ShimmerLoading(
      isLoading: _isLoading,
      child: CardGraphItem(isLoading: _isLoading),
    );
  }

  Widget _buildListItem(Operation operation) {
    return ShimmerLoading(
      isLoading: _isLoading,
      child: OperationCardListItem(
        operation: operation,
        isLoading: _isLoading,
      ),
    );
  }

  Widget _buildDetailsTable() {
    if (assets.isEmpty) {
      return Container();
    }
    FinancialAsset asset = assets[currentSelectedIndex - 1];
    return Container(
      alignment: Alignment.center,
      width: MediaQuery.of(context).size.width * 0.8,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Card(
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.3,
                    alignment: Alignment.centerLeft,
                    child: TextField(
                      readOnly: !_isEditing,
                      decoration: InputDecoration(
                        hintText: asset.name,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 16,
                  ),
                  IconButton(
                    onPressed: () {
                      _isEditing = !_isEditing;
                      setState(() {});
                    },
                    icon: _isEditing
                        ? Icon(
                            Icons.edit,
                            color: SilentiColors.primary,
                          )
                        : Icon(Icons.edit),
                  ),
                ],
              ),
              SizedBox(
                height: 8,
              ),
              DataTable(
                headingRowHeight: 0,
                columns: [
                  DataColumn(
                    label: Text(""),
                  ),
                  DataColumn(
                    label: Text(""),
                  ),
                ],
                rows: [
                  DataRow(cells: [
                    DataCell(
                      Text(
                        S.current.account,
                      ),
                    ),
                    DataCell(
                      TextField(
                        readOnly: !_isEditing,
                        decoration: InputDecoration(
                          hintText: asset.name,
                        ),
                      ),
                    )
                  ])
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> operationsResume = [];
    for (var operation in operations) {
      operationsResume.add(
        _buildListItem(operation),
      );
    }
    List<Widget> children = [
      SizedBox(height: 16),
      _buildTopRowList(assets),
      const SizedBox(height: 16),
      _buildGraphItem(),
      const SizedBox(height: 8),
      _buildDetailsTable(),
    ];

    return Shimmer(
      linearGradient: _shimmerGradient,
      child: ListView(
        physics: _isLoading ? const NeverScrollableScrollPhysics() : null,
        children: children,
      ),
    );
  }
}
