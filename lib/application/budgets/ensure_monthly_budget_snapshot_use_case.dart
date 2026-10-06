import 'package:silenti/application/shared/base_use_case.dart';
import 'package:silenti/application/shared/handle_result.dart';
import 'package:silenti/infraestructure/storage/budget_categories_dao.dart';
import 'package:silenti/infraestructure/storage/budget_category_snapshot_dao.dart';

/// PRD.md H1.6 / WORK_PLAN.md 2.2: freezes last month's budgeted amount for
/// every category — the first time this runs after that month has passed —
/// so a later edit to a category's live amount never rewrites what was
/// budgeted back then.
///
/// Minimal-design caveat (documented in WORK_PLAN.md 2.2, not fixed here):
/// the snapshot captures whatever amount is live *the first time this use
/// case runs after the month changed*. If nobody opens the app for an
/// entire month and the category amount is edited more than once before
/// the next run, only the value live at that next run is captured — not
/// the true value from back when that month was actually current. Call
/// this once per app session (e.g. at startup, alongside
/// MigrateDatabaseUseCase) to keep that drift as small as possible.
class EnsureMonthlyBudgetSnapshotUseCase extends BaseUseCase {
  final BudgetCategoriesDAO categoriesDao;
  final BudgetCategorySnapshotDao snapshotDao;
  EnsureMonthlyBudgetSnapshotUseCase({
    BudgetCategoriesDAO? categoriesDao,
    BudgetCategorySnapshotDao? snapshotDao,
  })  : categoriesDao = categoriesDao ?? BudgetCategoriesDAO(),
        snapshotDao = snapshotDao ?? BudgetCategorySnapshotDao(),
        super('EnsureMonthlyBudgetSnapshot');

  /// [now] is only for tests; production callers leave it out.
  Future<HandleResult<int>> execute({DateTime? now}) async {
    final result = HandleResult<int>();
    try {
      final today = now ?? DateTime.now();
      // The most recent month that has fully closed — DateTime normalizes
      // month 0 to December of the previous year, so this works in January
      // too.
      final lastMonth = DateTime(today.year, today.month - 1, 1);

      final categories = await categoriesDao.getBudgetCategories();
      var created = 0;
      for (final row in categories) {
        final inserted = await snapshotDao.insertIfMissing(
          categoryId: row['id'] as int,
          year: lastMonth.year,
          month: lastMonth.month,
          amount: (row['amount'] as num).toDouble(),
        );
        if (inserted) created++;
      }
      result.setData(created);
    } catch (e) {
      result.setError(e.toString());
    }
    return result;
  }
}
