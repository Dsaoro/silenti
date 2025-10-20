import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:silenti/application/financial_assets/create_financial_asset_use_case.dart';
import 'package:silenti/application/financial_assets/delete_financial_asset_use_case.dart';
import 'package:silenti/application/financial_assets/get_financial_assets.dart';
import 'package:silenti/application/financial_assets/get_asset_chart_data_use_case.dart';
import 'package:silenti/application/operations/get_operations_use_case.dart';
import 'package:silenti/core/enums/silenti_styles.dart';
import 'package:silenti/core/models/financial_asset.dart';
import 'package:silenti/core/models/operation.dart';
import 'package:silenti/generated/l10n.dart';
import 'package:silenti/presentation/forms/asset_form.dart';
import 'package:silenti/presentation/components/notification_popper.dart';
import 'package:silenti/presentation/components/silenti_datatable.dart';
import 'package:silenti/presentation/components/silenti_text_field.dart';
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
  List<FlSpot> chartData = [];
  int currentSelectedIndex = 0;

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
    await _getAssets();
    if (assets.isNotEmpty) {
      await _requestAssetOperations(currentSelectedIndex);
    }
    setState(() {
      _toggleLoading();
    });
  }

  _getAssets() async {
    var response = await GetFinancialAssets().execute();
    if (response.status) {
      setState(() {
        assets = response.model;
        if (assets.isNotEmpty) {
          _loadChartData(assets[currentSelectedIndex].id);
        }
      });
    } else {
      if (kDebugMode) {
        print("error getting assets");
      }
    }
  }

  _loadChartData(int assetId) async {
    var chartResponse = await GetAssetChartDataUseCase().executeByPeriod(
      financialAssetId: assetId,
      period: ChartPeriod.month, // Mostrar último mes por defecto
    );

    if (chartResponse.status) {
      setState(() {
        chartData = chartResponse.model;
      });
    } else {
      if (kDebugMode) {
        print("Error loading chart data: ${chartResponse.message}");
      }
      setState(() {
        chartData = [];
      });
    }
  }

  _selectAsset(int index) async {
    setState(() {
      currentSelectedIndex = index;
      _isLoading = true;
    });

    if (assets.isNotEmpty) {
      await _loadChartData(assets[index].id);
      await _requestAssetOperations(assets[index].id);
    }

    setState(() {
      _isLoading = false;
    });
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

  _deleteAsset(FinancialAsset asset) async {
    var response = await DeleteFinancialAssetUseCase().execute(asset.id);
    if (response.status && response.model > 0) {
      await _getDataFromDB();
      if (currentSelectedIndex >= assets.length) {
        if (kDebugMode) {
          print("current selected index: $currentSelectedIndex");
          print("current assets.length: ${assets.length}");
        }
        currentSelectedIndex = assets.indexOf(assets.last);
        if (kDebugMode) {
          print(
              "current selected index after operation: $currentSelectedIndex");
        }
      } else {
        if (kDebugMode) {
          print("currentSelectedIndex >= assets.length False");
          print("current selected index: $currentSelectedIndex");
          print("current assets.length: ${assets.length}");
        }
      }
      NotificationPopper(
        contentType: ContentType.success,
        title: "Sucess",
        message: "Account ${asset.name} deleted.",
      ).pop(context);
    } else {
      NotificationPopper(
        contentType: ContentType.failure,
        title: "Error",
        message: "Account ${asset.name} couldn´t be deleted, please try again.",
        // ignore: use_build_context_synchronously
      ).pop(context);
    }
  }

  _createNewAsset(FinancialAsset asset) async {
    var response = await CreateFinancialAssetUseCase().execute(asset);
    if (response.status && response.model > 0) {
      setState(() {
        _getDataFromDB();
        NotificationPopper(
          contentType: ContentType.success,
          title: "Sucess",
          message: "New account ${asset.name} added.",
        ).pop(context);
      });
    } else {
      NotificationPopper(
        contentType: ContentType.failure,
        title: "Error",
        message: "Account ${asset.name} couldn´t be added, please try again.",
        // ignore: use_build_context_synchronously
      ).pop(context);
    }
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
          _buildTopRowItem(Icons.attach_money, asset.name, () async {
            await _selectAsset(assets.indexOf(asset));
            setState(() {
              _isEditing = false;
            });
          }, currentSelectedIndex == assets.indexOf(asset)),
        );
      }
    }
    children.add(
      _buildTopRowItem(Icons.add, S.current.add, () {
        Dialog alert = Dialog(
          child: Scaffold(
            appBar: AppBar(
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
            body: Container(
              padding: EdgeInsets.all(16),
              width: MediaQuery.of(context).size.width,
              child: AssetForm(
                onSave: (value) {
                  if (value.runtimeType == FinancialAsset) {
                    _createNewAsset(value);
                  }
                  Navigator.pop(context);
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
          title: "${assets[currentSelectedIndex].name} - Balance History",
          chartData: chartData,
          showGrid: true,
          showTitles: true,
        ),
      );
    }
    return ShimmerLoading(
      isLoading: _isLoading,
      child: CardGraphItem(
        isLoading: _isLoading,
        chartData: [],
      ),
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
    FinancialAsset asset = assets[currentSelectedIndex];
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
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 32),
            alignment: Alignment.centerLeft,
            height: 60,
            child: Row(
              children: [
                if (_isEditing)
                  SizedBox(
                    width: 100,
                    height: 60,
                    child: SilentiTextField(
                      input: asset.name,
                      onChange: () {},
                      keyboardType: TextInputType.text,
                      readOnly: !_isEditing,
                    ),
                  ),
                if (!_isEditing)
                  SizedBox(
                    width: 100,
                    height: 50,
                    child: Text(
                      asset.name,
                      style: SilentiStyles.titleTextStyleDark(context),
                    ),
                  ),
                SizedBox(
                  width: 32,
                ),
                SizedBox(
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        _isEditing = !_isEditing;
                      });
                    },
                    icon: _isEditing
                        ? Icon(
                            Icons.edit,
                            size: 28,
                            color: Theme.of(context).colorScheme.onSurface,
                          )
                        : Icon(
                            Icons.edit,
                            size: 28,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                  ),
                )
              ],
            ),
          ),
          Container(
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.3,
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
                    return Theme.of(context).colorScheme.secondary;
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
                            style: SilentiStyles.titleTextStyleDark(context),
                          ),
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        Text(
                          S.current.deleteWarning(
                            S.current.asset,
                          ),
                        )
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        S.current.cancel,
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        if (currentSelectedIndex == 0 && assets.length == 1) {
                          NotificationPopper(
                            contentType: ContentType.warning,
                            title: "Error",
                            message:
                                "Account ${asset.name} couldn´t be deleted, you must have at least one account.",
                            // ignore: use_build_context_synchronously
                          ).pop(context);
                          return;
                        }
                        await _deleteAsset(asset);
                        // ignore: use_build_context_synchronously
                        setState(() {});
                        Navigator.pop(context);
                      },
                      child: Text(
                        S.current.delete,
                      ),
                    ),
                  ],
                );
                showDialog(
                    context: context,
                    builder: (context) {
                      return confirmation;
                    });
              },
              child: Text(
                S.current.delete,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAssetCard() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      width: MediaQuery.of(context).size.width * 0.7,
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
            height: MediaQuery.of(context).size.height * 0.7,
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
