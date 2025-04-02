import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:silenti/application/financial_assets/get_financial_assets.dart';
import 'package:silenti/application/operations/get_operations_use_case.dart';
import 'package:silenti/core/enums/silenti_colors.dart';
import 'package:silenti/core/enums/silenti_styles.dart';
import 'package:silenti/core/models/financial_asset.dart';
import 'package:silenti/core/models/operation.dart';
import 'package:silenti/generated/l10n.dart';
import 'package:silenti/infraestructure/storage/financial_assets_dao.dart';
import 'package:silenti/presentation/assets/asset_form.dart';
import 'package:silenti/presentation/components/silenti_datatable.dart';
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

  Widget _assetsOperationTable() {
    return SilentiDatatable(
      columns: [
        DataColumn(label: Text(S.current.date)),
        DataColumn(label: Text(S.current.amount)),
        DataColumn(label: Text(S.current.type)),
        DataColumn(label: Text(S.current.description)),
      ],
      rows: [],
    );
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

  _createNewAsset(FinancialAsset asset) async {
    FinancialAssetsDao dao = FinancialAssetsDao();
    if (kDebugMode) {
      print(asset.toMap());
    }
    dao.insertAccount(asset.toMap());
    //TODO save log for Asset Creation

    await Future.delayed(Duration(seconds: 2));
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
          child: Scaffold(
            appBar: AppBar(
              foregroundColor: SilentiColors.primary,
            ),
            body: Container(
              padding: EdgeInsets.all(16),
              width: MediaQuery.of(context).size.width,
              child: AssetForm(
                onSave: (value) {
                  if (value.runtimeType == FinancialAsset) {
                    _createNewAsset(value);
                  }
                  _createNewAsset(value);
                },
                asset: FinancialAsset(
                    0, "", 0.0, 1, 0.0, FinancialAssetFrequency.once),
                buttonText: S.current.register,
              ),
            ),
          ),
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
    if (kDebugMode) {
      print(
          "details for asset index ${currentSelectedIndex - 1}, named: ${asset.name}");
    }
    return Container(
      alignment: Alignment.center,
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.6,
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      child: Column(
        children: [
          Container(
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.40,
            child: AssetForm(
              onSave: (value) {
                if (value.runtimeType == FinancialAsset) {
                  if (kDebugMode) {
                    print("asset in edting mode:\n${value.toMap()}");
                  }
                }
              },
              asset: asset,
              readOnly: !_isEditing,
              showHead: false,
              showName: false,
              showButton: _isEditing,
              buttonText: S.current.update,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 32),
            alignment: Alignment.centerLeft,
            child: TextButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith(
                    (states) {
                      return SilentiColors.secondary;
                    },
                  ),
                ),
                onPressed: () {
                  AlertDialog confirmation = AlertDialog(
                    content: Container(
                      height: MediaQuery.of(context).size.height * 0.15,
                      alignment: Alignment.centerLeft,
                      child: Column(
                        children: [
                          Container(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              S.current.warning,
                              style: SilentiStyles.titleTextStyleDark,
                            ),
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          Text(S.current.deleteWarning(S.current.asset))
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(S.current.cancel),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(context);
                        },
                        child: Text(S.current.delete),
                      ),
                    ],
                  );
                  showDialog(
                      context: context,
                      builder: (context) {
                        return confirmation;
                      });
                },
                child: Text(S.current.delete)),
          )
        ],
      ),
    );
    // return
    // Container(
    //   alignment: Alignment.center,
    //   width: MediaQuery.of(context).size.width,
    //   height: MediaQuery.of(context).size.height * 0.5,
    //   child: AssetForm(
    //     onSave: (value) {
    //       if (value.runtimeType == FinancialAsset) {
    //         if (kDebugMode) {
    //           print("asset in edting mode:\n${value.toMap()}");
    //         }
    //       }
    //     },
    //     asset: asset,
    //     readOnly: !_isEditing,
    //     showHead: false,
    //     showName: false,
    //     showButton: _isEditing,
    //     buttonText: S.current.update,
    //   ),
    // );
  }

  Widget categoryResume() {
    Widget resume = Icon(Icons.reset_tv);
    return resume;
  }

  Widget categoryOperations() {
    Widget resume = Icon(Icons.plumbing);
    return resume;
  }

  Widget _buildAssetCard() {
    return Container(
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
                  child: Text(S.current.details),
                ),
                Tab(
                  child: Text(S.current.operations),
                )
              ],
            ),
          ),
          body: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.5,
            child: TabBarView(
              children: [
                _buildDetailsTable(),
                _assetsOperationTable(),
              ],
            ),
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
      _buildAssetCard(),
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
