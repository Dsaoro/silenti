# Silenti — Entity Relationships & Business Logic Audit

This document maps how Silenti's business entities relate to each other, traces
how a use case turns a UI action into database writes, and audits the current
implementation for correctness and layering problems. Every claim below was
verified by reading the referenced file — none of it is inferred from
`agents.md`'s target architecture, which in several places describes behavior
the code does not actually have (see `CLAUDE.md` for that gap).

## 1. Entity map

```
User (1 row, id=1)
  └─ authenticates the app (plaintext password compare)

FinancialAsset  (BankAccount | InvestmentAsset)
  ├─ id, name, includedOnBalance, frequency, balance/currentBalance
  ├─ 1—N BalanceHistory      (financialAssetId FK)
  └─ 1—N Operation           (Operation.financialAsset FK)

BudgetCategory  (type: 'income' | 'spent', self-referencing tree via parentId)
  ├─ 0—N BudgetCategory      (parentId FK — subcategories)
  └─ 1—N Operation           (Operation.category FK)

SpendSubCategories            <-- separate, parallel sub-category concept
  └─ category → BudgetCategory.id (FK, but conceptually unrelated to
     BudgetCategory.parentId tree — see §4.4)

Operation (income | spent)
  ├─ financialAsset → FinancialAsset.id
  ├─ category       → BudgetCategory.id
  └─ 0—1 BalanceHistory (BalanceHistory.operationId — the entry it produced)

BalanceHistory
  ├─ financialAssetId → FinancialAsset.id
  └─ operationId (nullable)  → Operation.id

Profit, Notification          <-- schema + DAO exist, zero application-layer
                                   callers anywhere in lib/ (dead)
```

None of the `FOREIGN KEY` clauses declared in
`infraestructure/adapters/secure_database_helper_pc.dart` are actually
enforced: nothing in the codebase runs `PRAGMA foreign_keys = ON` (grep across
`lib/` for `PRAGMA`/`foreign_keys`/`onConfigure` returns nothing), and SQLite
disables FK enforcement per connection by default. So every relationship above
is a **convention**, not a guarantee — orphaned `category`/`financialAsset`
ids are silently accepted (see §3.4).

## 2. How a feature turns into DB rows (data flow)

### 2.1 Register income / expense (the core money-movement path)

```
IncomeForm / SpendForm (presentation)
  → builds an Operation(type: "income"|"spent")
  → DepositInFinancialAssetUseCase / WithdrawFromFinancialAssetUseCase .execute()
       1. SaveOperationUSeCase.execute()          → OperationDAO.insertOperation()
          (INSERT INTO Operations, using Operation.toMap() — English columns)
       2. FinancialAssetsDao.deposit()/.withdraw()
          → raw UPDATE financial_assets SET balance = balance ± amount
          → re-SELECT the row to read the new balance
          → BalanceHistoryDAO.insertBalanceHistory(newBalance, operationId)
```
Three separate awaited DB round-trips, no `db.transaction()` wrapping any of
them (see §3.2 for the consequence).

### 2.2 Manage financial assets

```
AssetsPage
  → CreateFinancialAssetUseCase.execute(asset)   → FinancialAssetsDao.insertAccount()
  → DeleteFinancialAssetUseCase.execute(id)      → FinancialAssetsDao.deleteAccountById()
```
There is no third arrow to "update". `FinancialAssetsUpdateUseCase`
(`lib/application/financial_assets/financial_assets_update_use_case.dart`) is
an empty class with no `execute()` method at all, and nothing in
`lib/presentation/` calls `FinancialAssetsDao.updateAccountById()` either
(confirmed by grep). Editing an existing asset's name/balance/interest rate,
or refreshing an `InvestmentAsset.currentPrice`, is **not implemented** —
despite `assets_page.dart` carrying an `_isEditing` flag that suggests it once
was, or was meant to be.

### 2.3 Manage the budget

```
BudgetPage
  → GetExpensesCategoriesUseCase.execute()   → BudgetCategoriesDAO.getBudgetExpenses()
  → AddBudgetCategoryUseCase.execute()       → BudgetCategoriesDAO.insertBudgetCategory()
  → UpdateBudgetCategoryUseCase.execute()    → BudgetCategoriesDAO.updateBudgetCategory()
  → DeleteBudgetCategoryUseCase.execute()    → (nothing — see §3.1)
```
Every "new category" dialog in `budget_page.dart` hardcodes
`type: CategoryType.spent` (`lib/presentation/budget_page.dart:170` and
`:397`). `BudgetCategoriesDAO.getBudgetIncomes()`
(`lib/infraestructure/storage/budget_categories_dao.dart:57`) has **zero**
callers. Combined, the app has no path that ever creates or lists an
`income`-typed `BudgetCategory` — see §3.5.

### 2.4 Charts

```
AssetsPage / HomePageContent
  → GetAssetChartDataUseCase / GetTotalBalanceChartDataUseCase
       → BalanceHistoryDAO.getChartDataForAsset() / raw SUM(balance) query
       → maps rows to FlSpot for fl_chart
```
Charts read exclusively from `balance_history`, never by replaying
`Operations` — so any gap in the write path in §2.1 (see §3.2/§3.3) directly
produces a gap or a wrong point in every chart.

## 3. Business-logic audit

Findings are ordered by how much real damage they'd cause in normal use, most
severe first. Each was confirmed by reading the cited code, not guessed.

### 3.1 Deleting a budget category is a silent no-op — **Critical**
`lib/application/budgets/delete_budget_category_use_case.dart`:
```dart
Future<HandleResult<int>> execute(BudgetCategory budget) async {
  HandleResult<int> result = HandleResult<int>();
  return result;
}
```
It never touches `BudgetCategoriesDAO`. The only caller,
`lib/presentation/budget_page.dart:299`, checks
`response.status && response.model! > 0`; since `status` defaults to `false`
and `model` is `null`, that condition is always false, so the UI **always**
shows the failure toast *"couldn't be deleted, please try again"*
(`budget_page.dart:326-333`) — even though nothing actually failed, and the
category is never removed. This is user-visible on every attempt.

### 3.2 Deposit/withdraw report success even when the asset update failed — **Critical**
`FinancialAssetsDao.deposit()`/`.withdraw()`
(`lib/infraestructure/storage/financial_assets_dao.dart:56-98` and
`:100-147`) return `[]` when the target asset isn't found, only logging a
debug print. But their callers,
`DepositInFinancialAssetUseCase.execute()` / `WithdrawFromFinancialAssetUseCase.execute()`
(`lib/application/financial_assets/deposit_in_financial_asset_use_case.dart:36-43`,
`withdraw_from_financial_asset_use_case.dart:37-44`), never check that
response — they call `result.setData(true)` unconditionally after the DAO
call returns. Net effect: if `operation.financialAsset` doesn't exist (stale
id from a deleted asset, or a bug elsewhere), the app inserts the `Operation`
row, reports success to the user, but the balance is never updated and no
`BalanceHistory` row is written. The transaction list will show a phantom
operation that never affected any balance or chart.

### 3.3 No transactional atomicity across the 3-step money-movement write — **High**
Insert operation → update balance → insert balance history (§2.1) are three
independent `await`ed calls, not wrapped in `db.transaction()` (sqflite fully
supports this; it's simply not used anywhere in the DAOs). Any exception
between steps — including the "asset not found" path in §3.2 — leaves
partial state: an `Operations` row with no matching balance change, or a
changed balance with no history entry to explain it later.

### 3.4 No overdraft / negative-balance guard — **High**
`withdraw()` executes `UPDATE financial_assets SET balance = balance - $amount`
unconditionally (`financial_assets_dao.dart:119-121`). Neither the DAO, the
use case, nor `SpendForm` (`lib/presentation/operations/spend_form.dart:82-109`)
compares `amount` against the asset's current balance before submitting.
Balances can go arbitrarily negative with no warning — may be intentional for
credit accounts, but there's no `Frequency`/asset-type distinction that
suggests that was a deliberate design choice.

### 3.5 Income operations are categorized against expense categories — **High**
`IncomeForm._getCategories()`
(`lib/presentation/operations/income_form.dart:63-78`) populates its category
dropdown with `GetExpensesCategoriesUseCase().execute()` — the exact same
call `SpendForm` uses for expense categories
(`lib/presentation/operations/spend_form.dart:55-62`). There is no
`GetIncomeCategoriesUseCase`; the stub that should be it,
`GetIncomeTypesUseCase`
(`lib/application/budgets/get_income_types_use_case.dart`), has no `execute()`
method and is never instantiated anywhere. And as noted in §2.3, the UI never
creates an `income`-typed category to select in the first place. Result:
**every income `Operation.category` FK actually points at a `spent`-type
`BudgetCategory`.** Any report or chart that later joins operations to
categories by type will misclassify income.

### 3.6 "No results" is treated as an error, not a valid empty state — **Medium**
`GetOperations.byFinancialAsset/byFinancialAssetLimited/byBudgetCategoryLimited/getLastOperations`
(`lib/application/operations/get_operations_use_case.dart`) all end with:
```dart
if (operations.isNotEmpty) { result.setData(operations); }
else { result.setError("No operations found"); }
```
A brand-new asset or category with zero transactions is a completely normal
state, not a failure — but it's surfaced as one. Similarly,
`OperationDAO.getSpendByMonth()` uses `GROUP BY strftime('%m-%Y', date)`
(`lib/infraestructure/storage/operation_dao.dart:76-90`), which returns an
**empty list** (not a one-row null) when there are no operations in the
current month; `GetSpendsThisMonthUseCase.execute()`
(`lib/application/spends/get_spends_this_month_use_case.dart:13-23`) then
calls `value.first`, which throws `StateError: No element` on that empty
list, is caught by the surrounding `try`, and reported as a generic error.
In practice this is currently masked at both call sites —
`budget_page.dart` defaults `spentThisMonth = 0` on `!status`, and
`summary_card.dart:26-33` does `spentBalance.model ?? 0` — but that means a
*genuine* DB error is now indistinguishable from "nothing spent yet"
anywhere in the UI; failures are invisible.

### 3.7 Investment assets have no way to update `currentPrice`/`quantity` — **Medium**
`InvestmentAsset.toMap()` persists a denormalized `balance = quantity *
currentPrice` snapshot at creation time
(`lib/core/models/financial_asset.dart:126-138`), and
`GetFinancialAssetsBalanceUseCase` sums that stored column
(`get_financial_assets_balance_use_case.dart` → `getAccountBalance()`, a raw
`SUM(balance)`). Since §2.2 confirms there is no update path for any
financial asset, an investment's contribution to the total balance and to its
own balance-history chart is frozen at whatever price it was created with —
there is currently no code path capable of feeding the "market-price updates"
roadmap item in `agents.md` §3.2.

### 3.8 Budget category tree is silently truncated to two levels — **Low/Medium**
`BudgetCategory.subcategories` and the recursive `totalAmount` getter
(`lib/core/models/budget_category.dart:32-33`) are written to support
arbitrary nesting via `parentId`, and
`BudgetCategoriesDAO.getHierarchicalCategories()`
(`budget_categories_dao.dart:33-45`) even has a recursive CTE ready to fetch
it — but it's never called from any use case. The use case that's actually
wired to the UI, `GetExpensesCategoriesUseCase.execute()`
(`lib/application/budgets/get_expenses_categories_use_case.dart:14-40`),
only groups categories one level deep: children are attached to `parents`,
but each child keeps `subcategories: []` from `BudgetCategory.fromMap()`
(nothing re-attaches grandchildren). A third-level category would be fetched
from the DB but silently vanish from the tree the app renders.

### 3.9 Two disconnected sub-category systems — **Low**
`SpendSubCategories` (`lib/core/models/spend_sub_categories.dart`, table
`spend_sub_categories`) is what `SpendForm`'s "subcategory" dropdown actually
reads (`GetExpensesSubCategoriesUseCase().byId(id: category)`,
`spend_form.dart:64-71`). This is a flat table keyed by a `category` FK to a
`BudgetCategory` id — architecturally unrelated to `BudgetCategory.parentId`,
which is the tree `BudgetPage` lets the user edit. Two different "child of a
category" concepts coexist with no code bridging them; a subcategory created
in one place is invisible in the other's UI.

### 3.10 Dead/duplicate operation-registration path — **Low**
`OperationRegistrationUseCase`
(`lib/application/operations/transaction_registration_use_case.dart`) builds
its insert map with Spanish keys (`monto`, `fecha`, `descripcion`,
`categoria`, `tipo`) that don't match the actual `Operations` schema (which
uses `amount`, `date`, `description`, `category`, `type` — see
`Operation.toMap()`). It has no callers today (`SaveOperationUSeCase` is what
every use case actually calls), but it will silently write garbage columns if
anyone wires it up by mistake instead of `SaveOperationUSeCase`.

### 3.11 Dead schema/DAOs — **Low**
`profits` (`ProfitsDAO`) and `notifications` (`NotificacionDAO`) tables are
created and seeded in `onCreate` but have no application-layer callers
anywhere in `lib/` — pure scaffolding for roadmap features that were never
built out.

### 3.12 Unparameterized SQL for a numeric value — **Low**
`FinancialAssetsDao.deposit()`/`.withdraw()` build their `UPDATE` by
string-interpolating `amount` directly into `rawQuery`
(`financial_assets_dao.dart:71-72`, `:119-121`) instead of using bound
parameters, unlike every other query in the same file. The value is an
internal `double`, not user-supplied text, so this isn't an injection vector
today — but it's an inconsistent pattern that would become one if this method
is ever refactored to accept a caller-controlled string.

## 4. Layering / decoupling audit

### 4.1 Presentation → Infrastructure: genuinely decoupled ✔
A repo-wide grep for `Dao(`/`DAO(` inside `lib/presentation/` returns **zero
matches**. Every screen and form goes through a `*UseCase` class — the one
architectural rule from `agents.md` §4.1 that the code actually follows
consistently.

### 4.2 Application → Infrastructure: coupled to concrete classes, not abstractions ✘
Every use case instantiates its DAO(s) directly inside `execute()`, e.g.
`FinancialAssetsDao dao = FinancialAssetsDao();` inside
`create_financial_asset_use_case.dart:12`. There is no interface/constructor
injection anywhere (confirmed in `CLAUDE.md`: zero usages of
`injectable`/`get_it` despite being dependencies). Practical consequences:
- A use case cannot be unit-tested against a fake/mock DAO without changing
  its source — and indeed `test/` contains only the default
  `widget_test.dart`; there are no unit tests for any use case, even though
  `agents.md` §11.7 mandates a `mocktail`-based test per use case.
- `HandleResult<T>` is a reasonable boundary type, but most use cases add no
  logic beyond "call one DAO method, wrap the result/exception" — the
  application layer is structurally present but largely anemic; the real
  business rules that are missing (§3.2–§3.5) are missing everywhere, not
  merely misplaced in the wrong layer.

### 4.3 Core is not actually dependency-free ✘
`agents.md` §4.1 states "Core → anything else: not allowed" and describes
`core/models` as "Pure Dart entities (no Flutter deps)". In practice,
`FinancialAsset`'s `Frequency.label` getter
(`lib/core/models/financial_asset.dart:1-2, 12-27`) imports and calls into
`package:silenti/generated/l10n.dart` (`S.current.frecDaily`, etc.) — a
generated, Flutter-localization-dependent module. The domain layer is coupled
to the presentation/i18n stack, contradicting the project's own stated rule.

### 4.4 Validation lives in forms, not use cases ✘
Amount parsing/sanitization is reasonably kept in the widgets
(`SpendForm`/`IncomeForm`/`BudgetForm` all parse `TextField` input locally),
but domain-level validation that use cases should own — category must be
non-zero/exist, amount must be positive, withdrawal must not exceed balance —
exists **nowhere**, neither in the widget nor in the use case. A user who
never touches the category dropdown submits `Operation.category = 0`
(the forms' "select…" placeholder id), which isn't a real
`budget_categories.id` (autoincrement starts at 1); because FK enforcement is
off (§1), this is silently accepted into the database.

## 5. Summary table

| # | Finding | Severity | Location |
|---|---|---|---|
| 3.1 | Delete budget category is a no-op that always shows a false error | Critical | `application/budgets/delete_budget_category_use_case.dart` |
| 3.2 | Deposit/withdraw report success even if the asset wasn't found/updated | Critical | `deposit_in_financial_asset_use_case.dart`, `withdraw_from_financial_asset_use_case.dart` |
| 3.3 | No DB transaction around operation+balance+history writes | High | `infraestructure/storage/financial_assets_dao.dart` |
| 3.4 | No overdraft/negative-balance validation | High | `financial_assets_dao.dart:withdraw`, `spend_form.dart` |
| 3.5 | Income operations categorized against expense categories; income categories can't be created | High | `income_form.dart`, `budget_page.dart`, `get_income_types_use_case.dart` |
| 3.6 | Empty result sets reported as errors, masking real failures | Medium | `get_operations_use_case.dart`, `get_spends_this_month_use_case.dart` |
| 3.7 | No way to update an existing financial asset (rename, correct balance, reprice investment) | Medium | `financial_assets_update_use_case.dart` (stub), no DAO caller |
| 3.8 | Budget category tree silently truncated to 2 levels | Low/Medium | `get_expenses_categories_use_case.dart` |
| 3.9 | Two disconnected sub-category systems | Low | `spend_sub_categories_dao.dart` vs `BudgetCategory.parentId` |
| 3.10 | Dead use case with wrong (Spanish) column keys | Low | `operations/transaction_registration_use_case.dart` |
| 3.11 | Dead `profits`/`notifications` schema and DAOs | Low | `profits_dao.dart`, `notifications_dao.dart` |
| 3.12 | Unparameterized SQL for a numeric value | Low | `financial_assets_dao.dart:deposit/withdraw` |
| 4.2 | Use cases hard-wire concrete DAOs; no unit tests exist for any of them | Structural | all of `application/*` |
| 4.3 | `core/models` depends on generated i18n code | Structural | `core/models/financial_asset.dart` |
| 4.4 | No domain-level validation (category existence, positive amount, sufficient balance) | Structural | forms + use cases |

## 6. Suggested priority if this gets fixed

1. Fix `DeleteBudgetCategoryUseCase` (§3.1) and the deposit/withdraw
   success-check (§3.2) — both actively lie to the user about what happened.
2. Wrap the deposit/withdraw write path in a single `db.transaction()`
   (§3.3), and add a balance check before withdrawing (§3.4).
3. Give income operations their own category source — either wire
   `getBudgetIncomes()` into a real use case and let `BudgetPage` create
   `income`-typed categories, or, if income categorization isn't wanted yet,
   remove the misleading dropdown from `IncomeForm` (§3.5).
4. Decide whether "no rows" should ever be an error in
   `GetOperations`/`GetSpendsThisMonthUseCase` (§3.6) — as written, it hides
   genuine DB failures behind the same code path as "nothing to show yet."

This document intentionally doesn't fix anything — it's the audit requested.
See `CLAUDE.md` for the architecture/coupling context these findings sit on
top of.
