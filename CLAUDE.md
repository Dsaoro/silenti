# CLAUDE.md

Guidance for Claude Code when working in this repository. This file reflects the
**actual state of the code** (verified by reading it), not the aspirational
roadmap in `agents.md` — where the two disagree, a note below says so.

## Purpose

**Silenti** is a Flutter personal-finance / budget-tracking app whose core pitch
is privacy: all data is meant to stay on the user's device, with no cloud sync
and no telemetry. The user logs in with a local PIN/password, tracks
**financial assets** (bank accounts, investment holdings), records **income and
expense operations** against those assets, defines a **budget** of recurring
categories, and reviews **balance history** charts over time.

## Tech Stack

- Flutter (Material 3), Dart SDK `^3.6.1`.
- **Persistence:** `sqflite_common_ffi` + `sqlite3` — plain SQLite, same API on
  desktop and mobile. There is a commented-out `sqflite_sqlcipher` import in
  `secure_database_helper.dart`/`pubspec.yaml`: encryption-at-rest is
  **planned but not currently active**. The database opens with an empty
  password (`OpenSecureDatabaseUseCase().execute(password: "")`, see
  `lib/presentation/home_page.dart`).
- **Charts:** `fl_chart`.
- **i18n:** `intl` / `intl_utils`, ARB files in `lib/l10n/`, generated code in
  `lib/generated/` (do not hand-edit).
- Declared-but-unused dependencies: `flutter_riverpod`, `get_it`, `injectable`,
  `encrypt`. `agents.md` documents these as if they were load-bearing
  (Riverpod state management, `injectable`/`get_it` DI, AES encryption of
  data). **A repo-wide grep finds zero usages of any of them** — treat that
  part of `agents.md` as target architecture, not current behavior. Don't
  assume DI or Riverpod exist in code you haven't just read.

## Architecture (as implemented)

Layout follows a rough Clean Architecture split, but without the DI container
implied by `agents.md`. Layers talk to each other via **plain `new`ed classes**,
not injected interfaces:

```
lib/
├── core/
│   ├── models/     # Plain Dart entities: FinancialAsset, Operation,
│   │                 BudgetCategory, BalanceHistory, User
│   └── enums/      # SilentiColors, SilentiStyles
├── application/    # Use cases — one class per operation, each directly
│   ├── budgets/       instantiates the DAO(s) it needs (e.g. `OperationDAO()`
│   ├── financial_assets/  inside a use case's `execute()`), does NOT receive
│   ├── operations/     it via constructor injection.
│   ├── security/
│   ├── shared/     # BaseUseCase (just carries a `context` string), and
│   │                 HandleResult<T> — the result-wrapper every use case
│   │                 returns (`status`, `message`, `model`).
│   ├── spends/
│   └── storage/    # DB open + migration use cases
├── infraestructure/   # Note the Spanish spelling — used consistently in
│   ├── adapters/       imports and file paths. Do not "fix" it to
│   └── storage/        "infrastructure"; that would break every import.
│                        adapters/ = SecureDatabaseHelperPC (sqflite_ffi
│                        singleton, schema DDL + seed data).
│                        storage/  = one DAO per table (raw SQL, no ORM).
├── presentation/   # Pages + reusable widgets. Pages call use cases directly
│   ├── components/    (e.g. `home_page.dart` calls `OpenSecureDatabaseUseCase`
│   ├── forms/          and `MigrateDatabaseUseCase` in `initState`-style code).
│   ├── operations/     There is no state-management layer between them —
│   ├── security/       widgets use `setState`, not Riverpod providers.
│   └── theme/
├── generated/ / l10n/  # intl codegen — see "Localization" below
└── main.dart       # Initializes sqflite FFI, sets ThemeMode.system, opens on
                      # LoginPage()
```

Practical rule for edits: when adding a new capability, follow the existing
pattern — a `core/models` entity (with `toMap`/`fromMap`), a DAO method in
`infraestructure/storage/`, a use case in `application/*` that instantiates
that DAO and returns `HandleResult<T>`, and a presentation widget that calls
the use case directly. Don't introduce `injectable`/`get_it`/Riverpod
mid-file unless you're doing a deliberate, repo-wide migration — a single
provider next to plain `setState` everywhere else is inconsistent with
everything around it.

## Core Domain & Logic

- **`FinancialAsset`** (`core/models/financial_asset.dart`): abstract base,
  two subtypes reconstructed via `FinancialAsset.fromMap` based on a `type`
  discriminator column (`'BANK'` vs `'INVESTMENT'`):
  - `BankAccount` — stores `balance` directly.
  - `InvestmentAsset` — `currentBalance = quantity * currentPrice` (computed,
    not stored, though `toMap()` also persists it for easy querying).
- **`Operation`** — an income/expense transaction (`type` is the literal
  string `"income"` or `"spent"`, see `Operation.income`/`Operation.expense`
  constants), linked to a `financialAsset` id and a budget `category` id.
- **`BudgetCategory`** — a tree via nullable `parentId`; `totalAmount` is a
  recursive getter that sums a category's own `amount` plus every
  subcategory's `totalAmount`. Trees are reconstructed application-side in
  `GetExpensesCategoriesUseCase` (groups flat DB rows by `parentId`, attaches
  children to parents) — the DB does not do recursive queries.
- **`BalanceHistory`** — one row per balance-changing event, written
  automatically inside `FinancialAssetsDao.deposit()`/`withdraw()`. This is the
  system that powers the balance charts; see `BALANCE_HISTORY_IMPLEMENTATION.md`
  for the fuller design writeup (chart period filters, sampling, migration for
  existing installs).
- **Money flow for a transaction:**
  1. UI builds an `Operation` and calls `DepositInFinancialAssetUseCase` /
     `WithdrawFromFinancialAssetUseCase`.
  2. That use case first calls `SaveOperationUSeCase` to insert the operation
     row and get its new id.
  3. It then calls `FinancialAssetsDao.deposit()`/`withdraw()`, which updates
     `financial_assets.balance` with a raw SQL `UPDATE ... SET balance =
     balance ± <amount>` and, on success, inserts a `BalanceHistory` row
     tagged with that operation's id.
  4. Charts (`GetAssetChartDataUseCase`, `GetTotalBalanceChartDataUseCase`)
     read from `balance_history`, not by replaying operations.
  - Caveat: `deposit`/`withdraw` build the `UPDATE` with the amount
    string-interpolated directly into `rawQuery` rather than passed as a bound
    parameter. It's fed from an internal `double`, not raw user text, but if
    you touch this code, prefer `db.update(...)` with a `ROUND()`/args list
    or at minimum move the value into `whereArgs`-style binding — don't extend
    the interpolation pattern to new fields.
- **Auth** (`application/security/auth_use_case.dart`): a single local `User`
  row; `login()` does a **plaintext string comparison** of the password field
  (there is a literal `// In a real app we would hash the password here`
  comment). No hashing, no `encrypt` package usage despite it being a
  dependency. Treat "PIN authentication" as a screen-lock UX, not a security
  boundary, until this changes.
- **Two DAO/use-case paths for operations exist**: `SaveOperationUSeCase` (the
  one actually wired into deposit/withdraw, uses `Operation.toMap()` with
  English column names) and an apparently-unused
  `OperationRegistrationUseCase` that hand-builds a map with **Spanish keys**
  (`monto`, `fecha`, `descripcion`, `categoria`, `tipo`) that don't match the
  `operations` table schema. If you're touching operation registration, use
  `SaveOperationUSeCase`'s pattern; don't extend
  `OperationRegistrationUseCase` without first checking whether it's dead code.
- **Database schema** lives as inline DDL strings in
  `infraestructure/adapters/secure_database_helper_pc.dart` (`onCreate`), plus
  incremental migration logic in
  `application/storage/migrate_database_use_case.dart` for the
  `balance_history` table specifically (added after initial release, so
  existing installs need a runtime migration rather than a bump of `version:`
  in `openDatabase`).

## Localization

- Source strings: `lib/l10n/*.arb`. Generated: `lib/generated/` (via
  `flutter_intl`) — don't hand-edit generated files.
- After changing ARB files: `dart run intl_utils:generate`.
- Access pattern: `S.of(context).<key>` inside widgets, `S.current.<key>`
  outside the widget tree (e.g. inside `Frequency.label` in
  `core/models/financial_asset.dart`).

## Development Workflow

```sh
flutter pub get
dart run intl_utils:generate   # after editing lib/l10n/*.arb
flutter test
flutter run -d windows         # or -d linux / an attached Android device
```

Note: `build_runner`/`injectable_generator` are declared dev dependencies but
there is nothing currently annotated with `@injectable`/`@lazySingleton` to
generate — don't assume running `build_runner` produces DI wiring today.

## Related Docs

- `agents.md` — the project's target/aspirational architecture and roadmap
  (Clean Architecture layer rules, planned DI/state-management/encryption
  choices, MVP checklist). Useful for direction; verify against actual code
  (as this file does) before relying on a specific claim.
- `BALANCE_HISTORY_IMPLEMENTATION.md` — detailed design notes for the balance
  history/chart feature described above.
- `README.md` — user-facing feature pitch (mentions Sembast as storage, which
  is stale; the app actually uses `sqflite_common_ffi`/SQLite).
