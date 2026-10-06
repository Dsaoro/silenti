import 'package:silenti/application/budgets/get_expenses_categories_use_case.dart';
import 'package:silenti/application/budgets/get_income_categories_use_case.dart';
import 'package:silenti/application/shared/base_use_case.dart';
import 'package:silenti/application/shared/handle_result.dart';

/// Totals for PRD.md H1.4: budgeted income vs. budgeted expense, so the
/// user can see at a glance whether their planned spending exceeds planned
/// income. `deficit` is negative when expense > income — PRD.md §5 decided
/// this is purely informative and never blocks saving a budget.
class BudgetSummary {
  final double totalIncome;
  final double totalExpense;
  const BudgetSummary({
    required this.totalIncome,
    required this.totalExpense,
  });

  double get deficit => totalIncome - totalExpense;
}

class GetBudgetSummaryUseCase extends BaseUseCase {
  final GetIncomeCategoriesUseCase incomeUseCase;
  final GetExpensesCategoriesUseCase expenseUseCase;
  GetBudgetSummaryUseCase({
    GetIncomeCategoriesUseCase? incomeUseCase,
    GetExpensesCategoriesUseCase? expenseUseCase,
  })  : incomeUseCase = incomeUseCase ?? GetIncomeCategoriesUseCase(),
        expenseUseCase = expenseUseCase ?? GetExpensesCategoriesUseCase(),
        super('GetBudgetSummary');

  Future<HandleResult<BudgetSummary>> execute() async {
    final result = HandleResult<BudgetSummary>();
    final incomeResult = await incomeUseCase.execute();
    final expenseResult = await expenseUseCase.execute();

    if (!incomeResult.status || !expenseResult.status) {
      result.setError('Could not load the budget summary');
      return result;
    }

    // totalAmount already sums a root category's own amount plus its
    // subcategories' (BudgetCategory.totalAmount) — summing that per root,
    // instead of also adding subcategories separately, avoids double
    // counting them.
    final totalIncome =
        incomeResult.model!.fold(0.0, (sum, c) => sum + c.totalAmount);
    final totalExpense =
        expenseResult.model!.fold(0.0, (sum, c) => sum + c.totalAmount);

    result.setData(
      BudgetSummary(totalIncome: totalIncome, totalExpense: totalExpense),
    );
    return result;
  }
}
