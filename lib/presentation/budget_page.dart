import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:silenti/application/budgets/add_budget_category_use_case.dart';
import 'package:silenti/application/budgets/delete_budget_category_use_case.dart';
import 'package:silenti/application/budgets/get_expenses_categories_use_case.dart';
import 'package:silenti/application/operations/get_operations_use_case.dart';
import 'package:silenti/core/enums/silenti_colors.dart';
import 'package:silenti/core/models/budget_category.dart';

import 'package:silenti/core/models/operation.dart';
import 'package:silenti/generated/l10n.dart';
import 'package:silenti/presentation/components/notification_popper.dart';
import 'package:silenti/presentation/components/silenti_datatable.dart';
import 'package:silenti/presentation/components/silenti_text_field.dart';
import 'package:silenti/presentation/forms/budget_form.dart';
import 'package:silenti/presentation/components/category_status_widget.dart';
import 'package:silenti/application/budgets/update_budget_category_use_case.dart';
import 'components/card_graph_item.dart';
import 'components/operation_card_list_item.dart';
import 'components/circle_list_item.dart';
import 'components/shimmer.dart';
import 'components/shimmer_loading.dart';

class BudgetPage extends StatefulWidget {
  const BudgetPage({super.key});

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  bool _isLoading = true;
  bool _isEditing = false;
  List<BudgetCategory> categories = [];
  List<Operation> operations = [];
  int currentSelectedIndex = 0;
  double spentThisMonth = 0;
  Map<int, double> _spentBySubcategory = {};

  void _toggleLoading() {
    setState(() {
      _isLoading = false;
    });
  }

  Widget _budgetsOperationTable() {
    return SilentiDatatable(
      columns: [
        DataColumn(
          label: Text(
            S.current.date,
          ),
        ),
        DataColumn(
          label: Text(
            S.current.amount,
          ),
        ),
        DataColumn(
          label: Text(
            S.current.type,
          ),
        ),
        DataColumn(
          label: Text(
            S.current.description,
          ),
        ),
      ],
      rows: [],
    );
  }

  Widget _budgetStatus() {
    if (categories.isEmpty) return Container();
    final budget = categories[currentSelectedIndex];

    // The main category amount is the sum of its subcategories if it has any, otherwise its own amount.
    // However, the rules specify that if we modify subcategories, it updates the main.
    // The totalAmount getter does exactly what we want (sum of itself + subcategories).
    // Let's use it for the display of total budgeted amount for the parent.
    final totalBudgeted = budget.subcategories.isNotEmpty
        ? budget.subcategories.fold(0.0, (sum, item) => sum + item.amount)
        : budget.amount;

    // total spent includes the main category spent + all subcategories spent
    double totalSpent = spentThisMonth;
    for (var sub in budget.subcategories) {
      totalSpent += _spentBySubcategory[sub.id] ?? 0.0;
    }

    final percent = totalBudgeted > 0 ? (totalSpent / totalBudgeted) : 0.0;
    final remaining = totalBudgeted - totalSpent;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: ListView(
        children: [
          CategoryStatusWidget(
            percent: percent,
            remaining: remaining,
            spentThisMonth: totalSpent,
            title: "Consumo mensual (Total)",
          ),
          const SizedBox(height: 16),
          if (budget.subcategories.isNotEmpty) ...[
            const Divider(),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text("Subcategorías",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            ...budget.subcategories.map((sub) {
              final subSpent = _spentBySubcategory[sub.id] ?? 0.0;
              final subPercent = sub.amount > 0 ? (subSpent / sub.amount) : 0.0;
              final subRemaining = sub.amount - subSpent;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: CategoryStatusWidget(
                  percent: subPercent,
                  remaining: subRemaining,
                  spentThisMonth: subSpent,
                  title: sub.name,
                  onLongPress: () {
                    _showEditSubcategoryDialog(sub);
                  },
                ),
              );
            }),
          ],
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.add_circle_outline),
            title: const Text("Agregar subcategoría"),
            onTap: () {
              _showAddSubcategoryDialog(budget);
            },
          )
        ],
      ),
    );
  }

  void _showAddSubcategoryDialog(BudgetCategory parent) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Scaffold(
            appBar: AppBar(
              foregroundColor: SilentiColors.primary,
              title: const Text("Nueva Subcategoría"),
            ),
            body: Container(
              padding: const EdgeInsets.all(16),
              width: MediaQuery.of(context).size.width,
              child: BudgetForm(
                onSave: (value) async {
                  if (value is BudgetCategory) {
                    await _createNewBudget(value);
                  }
                },
                budget: BudgetCategory(
                    amount: 0,
                    id: 0,
                    parentId: parent.id,
                    name: "",
                    type: CategoryType.spent,
                    firstTime: DateTime.now(),
                    frequency: parent.frequency),
                buttonText: S.current.register,
              ),
            ),
          ),
        );
      },
    );
  }

  void _showEditSubcategoryDialog(BudgetCategory subcategory) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Scaffold(
            appBar: AppBar(
              foregroundColor: SilentiColors.primary,
              title: const Text("Editar Subcategoría"),
            ),
            body: Container(
              padding: const EdgeInsets.all(16),
              width: MediaQuery.of(context).size.width,
              child: BudgetForm(
                onSave: (value) async {
                  if (value is BudgetCategory) {
                    var response = await UpdateBudgetCategoryUseCase()
                        .execute(category: value);
                    if (response.status && response.model! > 0) {
                      setState(() {
                        _getDataFromDB();
                        NotificationPopper(
                          contentType: ContentType.success,
                          title: "Sucess",
                          message: "Account ${value.name} updated.",
                        ).pop(context);
                      });
                    } else {
                      NotificationPopper(
                        contentType: ContentType.failure,
                        title: "Error",
                        message:
                            "Account ${value.name} couldn´t be updated, please try again.",
                      ).pop(context);
                    }
                  }
                },
                budget: subcategory,
                buttonText: S.current.update,
              ),
            ),
          ),
        );
      },
    );
  }

  _getDataFromDB() async {
    await _requestBudgetCategories();
    if (categories.isNotEmpty) {
      if (currentSelectedIndex >= categories.length) {
        currentSelectedIndex = 0;
      }
      await _requestBudgetOperations(categories[currentSelectedIndex].id);
    }
    setState(() {
      _toggleLoading();
    });
  }

  _requestBudgetCategories() async {
    var response = await GetExpensesCategoriesUseCase().execute();
    if (response.status) {
      categories = response.model!;
    }
  }

  _requestBudgetOperations(int budgetId) async {
    final now = DateTime.now();

    // Get last operations for the main category
    var opResponse =
        await GetOperations().byBudgetCategoryLimited(budgetId, limit: 6);

    // Get monthly spent for the main category
    var spentResponse = await GetOperations()
        .getSpentAmountByCategoryAndMonth(budgetId, now.month, now.year);

    // Get spent for each subcategory
    Map<int, double> subcategorySpent = {};
    if (categories.isNotEmpty && currentSelectedIndex < categories.length) {
      final currentBudget = categories[currentSelectedIndex];
      for (var sub in currentBudget.subcategories) {
        var subSpentRes = await GetOperations()
            .getSpentAmountByCategoryAndMonth(sub.id, now.month, now.year);
        if (subSpentRes.status) {
          subcategorySpent[sub.id] = subSpentRes.model!;
        }
      }
    }

    setState(() {
      if (opResponse.status) {
        operations = opResponse.model!;
      } else {
        operations = [];
      }

      if (spentResponse.status) {
        spentThisMonth = spentResponse.model!;
      } else {
        spentThisMonth = 0;
      }

      _spentBySubcategory = subcategorySpent;

      _toggleLoading();
    });
  }

  @override
  void initState() {
    _getDataFromDB();
    super.initState();
  }

  _deleteBudget(BudgetCategory budget) async {
    var response = await DeleteBudgetCategoryUseCase().execute(budget);
    if (response.status && response.model! > 0) {
      await _getDataFromDB();
      if (currentSelectedIndex >= categories.length) {
        if (kDebugMode) {
          print("current selected index: $currentSelectedIndex");
          print("current categories.length: ${categories.length}");
        }
        currentSelectedIndex = categories.indexOf(categories.last);
        if (kDebugMode) {
          print(
              "current selected index after operation: $currentSelectedIndex");
        }
      } else {
        if (kDebugMode) {
          print("currentSelectedIndex >= categories.length False");
          print("current selected index: $currentSelectedIndex");
          print("current categories.length: ${categories.length}");
        }
      }
      NotificationPopper(
        contentType: ContentType.success,
        title: "Sucess",
        message: "Account ${budget.name} deleted.",
        // ignore: use_build_context_synchronously
      ).pop(context);
    } else {
      NotificationPopper(
        contentType: ContentType.failure,
        title: "Error",
        message:
            "Account ${budget.name} couldn´t be deleted, please try again.",
        // ignore: use_build_context_synchronously
      ).pop(context);
    }
  }

  _createNewBudget(BudgetCategory budget) async {
    var response = await AddBudgetCategoryUseCase().execute(category: budget);
    if (response.status && response.model! > 0) {
      setState(() {
        _getDataFromDB();
        NotificationPopper(
          contentType: ContentType.success,
          title: "Sucess",
          message: "New account ${budget.name} added.",
        ).pop(context);
      });
    } else {
      NotificationPopper(
        contentType: ContentType.failure,
        title: "Error",
        message: "Account ${budget.name} couldn´t be added, please try again.",
        // ignore: use_build_context_synchronously
      ).pop(context);
    }
    await Future.delayed(Duration(seconds: 2));
  }

  Widget _buildTopRowList(List<BudgetCategory> categories) {
    List<Widget> children = [
      const SizedBox(width: 16),
    ];
    if (kDebugMode) {
      print("build top row list  ${categories.isNotEmpty}");
    }
    if (categories.isNotEmpty) {
      for (var budget in categories) {
        children.add(
          _buildTopRowItem(Icons.attach_money, budget.name, () {
            setState(() {
              currentSelectedIndex = categories.indexOf(budget);
              _isEditing = false;
            });
          }, currentSelectedIndex == categories.indexOf(budget)),
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
              child: BudgetForm(
                onSave: (value) {
                  if (value is BudgetCategory) {
                    _createNewBudget(value);
                  }
                },
                budget: BudgetCategory(
                    amount: 50000,
                    id: 0,
                    name: "",
                    type: CategoryType.spent,
                    firstTime: DateTime.now(),
                    frequency: "monthly"),
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
    if (categories.isNotEmpty) {
      return ShimmerLoading(
        isLoading: _isLoading,
        child: CardGraphItem(
          isLoading: _isLoading,
          title:
              "${categories[currentSelectedIndex].name}    (\$${categories[currentSelectedIndex].amount})",
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
    if (categories.isEmpty) {
      return Container();
    }
    BudgetCategory budget = categories[currentSelectedIndex];
    if (kDebugMode) {
      print(
          "details for budget index $currentSelectedIndex , named: ${budget.name}");
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
                      input: budget.name,
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
                      budget.name,
                      style: Theme.of(context).textTheme.titleLarge,
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
                            color: SilentiColors.dark,
                          )
                        : Icon(
                            Icons.edit,
                            size: 28,
                            color: SilentiColors.primary,
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
            child: BudgetForm(
              onSave: (value) {
                if (value is BudgetCategory) {
                  if (kDebugMode) {
                    print("budget in edting mode:\n${value.toMap()}");
                  }
                }
              },
              budget: budget,
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
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        Text(
                          S.current.deleteWarning(
                            "Budget",
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
                        if (currentSelectedIndex == 0 &&
                            categories.length == 1) {
                          NotificationPopper(
                            contentType: ContentType.warning,
                            title: "Error",
                            message:
                                "Account ${budget.name} couldn´t be deleted, you must have at least one account.",
                            // ignore: use_build_context_synchronously
                          ).pop(context);
                          return;
                        }
                        await _deleteBudget(budget);
                        setState(() {});
                        // ignore: use_build_context_synchronously
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
                  color: SilentiColors.dark,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBudgetCard() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      width: MediaQuery.of(context).size.width * 0.7,
      padding: EdgeInsets.all(3),
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              tabs: [
                Tab(
                  child: Text(
                    S.current.status,
                  ),
                ),
                Tab(
                  child: Text(
                    S.current.operations,
                  ),
                ),
                Tab(
                  child: Text(
                    S.current.details,
                  ),
                ),
              ],
            ),
          ),
          body: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.7,
            child: TabBarView(
              children: [
                _budgetStatus(),
                _budgetsOperationTable(),
                _buildDetailsTable(),
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
      _buildTopRowList(categories),
      const SizedBox(height: 16),
      _buildGraphItem(),
      const SizedBox(height: 8),
      _buildBudgetCard(),
    ];

    return Shimmer(
      linearGradient: shimmerGradientDefault,
      child: ListView(
        physics: _isLoading ? const NeverScrollableScrollPhysics() : null,
        children: children,
      ),
    );
  }
}
