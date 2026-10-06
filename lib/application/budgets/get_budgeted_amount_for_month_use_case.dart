import 'package:silenti/application/shared/base_use_case.dart';
import 'package:silenti/application/shared/handle_result.dart';
import 'package:silenti/infraestructure/storage/budget_categories_dao.dart';
import 'package:silenti/infraestructure/storage/budget_category_snapshot_dao.dart';

/// PRD.md H1.6: the amount budgeted for a category in a given month — the
/// live `budget_categories.amount` for the current or a future month, or
/// the frozen `budget_category_snapshot` for a past month (0.0 if none was
/// ever recorded for it, meaning the app wasn't opened that month while it
/// was still current — see EnsureMonthlyBudgetSnapshotUseCase).
class GetBudgetedAmountForMonthUseCase extends BaseUseCase {
  final BudgetCategoriesDAO categoriesDao;
  final BudgetCategorySnapshotDao snapshotDao;
  GetBudgetedAmountForMonthUseCase({
    BudgetCategoriesDAO? categoriesDao,
    BudgetCategorySnapshotDao? snapshotDao,
  })  : categoriesDao = categoriesDao ?? BudgetCategoriesDAO(),
        snapshotDao = snapshotDao ?? BudgetCategorySnapshotDao(),
        super('GetBudgetedAmountForMonth');

  /// [now] is only for tests; production callers leave it out.
  Future<HandleResult<double>> execute({
    required int categoryId,
    required int year,
    required int month,
    DateTime? now,
  }) async {
    final result = HandleResult<double>();
    try {
      final today = now ?? DateTime.now();
      final isPast =
          year < today.year || (year == today.year && month < today.month);

      if (isPast) {
        final snapshot =
            await snapshotDao.getSnapshot(categoryId, year, month);
        result.setData(
            snapshot == null ? 0.0 : (snapshot['amount'] as num).toDouble());
        return result;
      }

      final category = await categoriesDao.getById(categoryId);
      result.setData(
          category == null ? 0.0 : (category['amount'] as num).toDouble());
    } catch (e) {
      result.setError(e.toString());
    }
    return result;
  }
}
