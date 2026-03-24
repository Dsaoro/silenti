# Silenti – Agent Context Document

> **Intended audience:** AI coding assistants (Copilot, Gemini, Claude, GPT-4, etc.).  
> This file provides the authoritative context for the **Silenti** project so that any AI model can understand the codebase, constraints, and conventions before contributing code or suggestions.

---

## 1. Project Overview

**Silenti** is a **privacy-first, offline budget-tracking mobile/desktop application** built with Flutter.

| Field | Value |
|---|---|
| Package name | `silenti` |
| Current version | `0.0.1+1` |
| Dart SDK | `^3.6.1` |
| Flutter | Material 3 |
| Primary language | Dart |
| Target platforms | Android, Windows |

### Design Philosophy
- **No cloud, no telemetry.** All data lives on the user's device.
- **Encryption at rest.** Sensitive data is encrypted using AES (`encrypt: ^5.0.3`).
- **Simplicity over feature bloat.** Every UI decision must reduce cognitive load.
- **Accessible offline backups.** Encrypted exports the user can store anywhere.

---

## 2. AI Agent Requirements

> [!IMPORTANT]
> **Expert-level Flutter knowledge is required** to contribute to this project.  
> Contributors (human or AI) must be proficient in:
> - **Riverpod 2.x** state management patterns (`flutter_riverpod ^2.6.1`).
> - **Injectable / get_it** dependency injection (`injectable ^2.7.1`, `get_it ^9.2.0`).
> - **SQLite FFI** via `sqflite_common_ffi` — raw SQL queries, DAOs, migrations.
> - **Material 3** theming — `Theme.of(context)` must be used for all colors; no hardcoded hex values in widgets.
> - **Flutter localizations (`intl`)** — all user-visible strings must use `S.of(context).<key>` or `S.current.<key>`.
> - **Clean Architecture** layering — never access a DAO directly from a widget.
> - **`fl_chart`** for data visualization components.

---

## 3. Project Goals (Roadmap)

### 3.1 Core Goals (MVP)
- [x] Local SQLite database with encrypted storage.
- [x] User PIN authentication (login screen).
- [x] Manage **Financial Assets** (bank accounts, investment accounts).
- [x] Register income and expense **Operations** linked to assets and budget categories.
- [x] **Budget Categories** with hierarchical subcategories and frequency-based amounts.
- [x] **Balance History** snapshots per asset.
- [ ] Encrypted backup / restore to external storage.
- [ ] Full i18n coverage (EN + ES).

### 3.2 Future Goals
- [ ] Recurring transaction automation.
- [ ] Advanced analytics: spending trends, savings rate, budget adherence charts.
- [ ] Investment portfolio valuation with market-price updates.
- [ ] Widget/shortcut for quick expense entry (Android/iOS).
- [ ] Biometric authentication (fingerprint / Face ID).

---

## 4. Architecture

Silenti follows **Clean Architecture** with four clear layers:

```
lib/
├── core/                  # Domain layer
│   ├── models/            # Pure Dart entities (no Flutter deps)
│   └── enums/             # Shared enumerations
│
├── application/           # Use-case layer (business logic)
│   ├── budgets/           # BudgetCategory use cases
│   ├── financial_assets/  # FinancialAsset use cases
│   ├── operations/        # Operation (transaction) use cases
│   ├── security/          # Auth / encryption use cases
│   ├── storage/           # DB initialization / migration use cases
│   ├── spends/            # Spend sub-category use cases
│   └── shared/            # Shared application services
│
├── infraestructure/       # Data layer (note: project uses "infraestructure" spelling)
│   ├── storage/           # DAO implementations (SQLite FFI)
│   └── adapters/          # External service adapters
│
├── presentation/          # UI layer
│   ├── components/        # Reusable widgets
│   ├── forms/             # Form widgets
│   ├── operations/        # Operation-specific screens
│   ├── security/          # Login / PIN screens
│   ├── theme/             # Theme definitions (light + dark)
│   ├── assets_page.dart
│   ├── budget_page.dart
│   ├── home_page.dart
│   └── ...
│
├── generated/             # Auto-generated intl files (do not edit manually)
├── l10n/                  # ARB translation source files
└── main.dart              # App entry point
```

### 4.1 Layer Rules (STRICT)
| From → To | Allowed? |
|---|---|
| Presentation → Application (use case) | ✅ Yes |
| Presentation → Infrastructure (DAO) | ❌ No |
| Application → Infrastructure (DAO) | ✅ Yes |
| Application → Core (models) | ✅ Yes |
| Infrastructure → Core (models) | ✅ Yes |
| Core → anything else | ❌ No |

### 4.2 Dependency Injection
- All services and DAOs are registered via `injectable` / `get_it`.
- Run `dart run build_runner build --delete-conflicting-outputs` after adding or modifying injectable classes.

### 4.3 State Management
- All state is managed with **Riverpod** (`flutter_riverpod`).
- Use `AsyncNotifierProvider` or `NotifierProvider` for use-case-driven state.
- Avoid `setState` except for purely local ephemeral UI state.

---

## 5. Core Domain Models

### `FinancialAsset` (`lib/core/models/financial_asset.dart`)
Abstract base for all financial accounts. Two concrete subtypes:

| Subtype | Key fields |
|---|---|
| `BankAccount` | `balance`, `interestRate` |
| `InvestmentAsset` | `quantity`, `currentPrice`, `tickerSymbol` (computed: `currentBalance = quantity * currentPrice`) |

Common fields: `id`, `name`, `includedOnBalance` (1/0), `frequency` (`Frequency` enum).

### `Operation` (`lib/core/models/operation.dart`)
A single financial transaction.

| Field | Type | Notes |
|---|---|---|
| `id` | `int` | Auto-increment PK |
| `financialAsset` | `int` | FK → `financial_assets` |
| `amount` | `double` | Always positive |
| `date` | `DateTime` | ISO-8601 stored in DB |
| `description` | `String` | Free text |
| `category` | `int` | FK → `budget_categories` |
| `type` | `String` | `"income"` or `"spent"` |

### `BudgetCategory` (`lib/core/models/budget_category.dart`)
Hierarchical category tree (parent / child via `parentId`).

| Field | Type | Notes |
|---|---|---|
| `id` | `int` | Auto-increment PK |
| `parentId` | `int?` | `null` for root categories |
| `type` | `String` | `"income"` or `"spent"` |
| `name` | `String` | Display label |
| `amount` | `double` | Budgeted amount |
| `frequency` | `String` | Matches `Frequency` enum values |
| `firstTime` | `DateTime` | Budget start date |
| `subcategories` | `List<BudgetCategory>` | Loaded separately; `totalAmount` is recursive |

### `BalanceHistory` (`lib/core/models/balance_history.dart`)
Snapshot of an asset's balance at a point in time (used for trend charts).

### `User` (`lib/core/models/user.dart`)
Local user model for PIN-based authentication.

---

## 6. Database Layer

- **Engine:** SQLite via `sqflite_common_ffi` (supports desktop + mobile with the same API).
- **DAOs** live in `lib/infraestructure/storage/` — one DAO per table/entity.

| DAO file | Responsibility |
|---|---|
| `financial_assets_dao.dart` | CRUD for assets |
| `operation_dao.dart` | CRUD + filtered queries for transactions |
| `budget_categories_dao.dart` | CRUD + hierarchical reconstruction |
| `balance_history_dao.dart` | Insert & fetch balance snapshots |
| `user_dao.dart` | PIN storage / verification |
| `notifications_dao.dart` | Pending notification records |
| `profits_dao.dart` | Income/profit summaries |
| `spend_sub_categories_dao.dart` | Subcategory quick lookups |

> [!NOTE]
> The database is initialized/migrated through use cases in `lib/application/storage/`.  
> Never call DAO methods directly from widgets or providers — always go through a use case.

---

## 7. Key Dependencies

| Package | Version | Purpose |
|---|---|---|
| `flutter_riverpod` | `^2.6.1` | State management |
| `get_it` + `injectable` | `^9.2.0` / `^2.7.1` | Dependency injection |
| `sqflite_common_ffi` | `^2.3.5` | SQLite on all platforms |
| `sqlite3` | `^2.7.4` | Low-level SQLite bindings |
| `encrypt` | `^5.0.3` | AES encryption |
| `path_provider` | `^2.1.5` | Platform-safe file paths |
| `fl_chart` | `^0.70.2` | Charts & graphs |
| `intl` / `intl_utils` | `any` / `^2.8.10` | Internationalization |
| `awesome_snackbar_content` | `^0.1.5` | Styled snackbar feedback |

---

## 8. UI & Theming Conventions

- **Always** use `Theme.of(context).colorScheme.*` and `Theme.of(context).textTheme.*`. Never hardcode colors.
- Light and dark themes are defined in `lib/presentation/theme/silenti_themes.dart`.
- The app respects `ThemeMode.system` — all widgets must look correct in both modes.
- Navigation uses a custom `SilentiNavigationBar` component.
- Loading states use `Shimmer` / `ShimmerLoading` components (`lib/presentation/components/shimmer*.dart`).
- Feedback messages use `awesome_snackbar_content` via `NotificationPopper`.

### Reusable Components (`lib/presentation/components/`)
| Widget | Purpose |
|---|---|
| `SilentiTextField` | Styled text input |
| `SilentiDropdown` | Styled dropdown selector |
| `SilentiDatePicker` | Date selection widget |
| `SilentiDataTable` | Paginated data table for asset transactions |
| `SilentiTransactionTable` | Rich transaction history table with filters |
| `ResumeCard` / `SummaryCard` | Balance / summary display cards |
| `CardGraphItem` | Chart card wrapper with `fl_chart` |
| `OperationCardListItem` | Transaction list tile |
| `CategoryButton` | Budget category selection chip |

---

## 9. Localization

- Source files: `lib/l10n/*.arb`
- Generated output: `lib/generated/` (do **not** edit manually)
- Config: `l10n.yaml` + `flutter_intl` section in `pubspec.yaml`
- All user-visible strings must be added to the ARB files and referenced as `S.of(context).<key>` (in `build`) or `S.current.<key>` (outside widget tree).
- After adding/modifying ARB keys run: `dart run intl_utils:generate`

---

## 10. Development Workflow

```sh
# Install dependencies
flutter pub get

# Generate DI + l10n code
dart run build_runner build --delete-conflicting-outputs
dart run intl_utils:generate

# Run the app (desktop for fast iteration)
flutter run -d windows

# Run tests
flutter test
```

> [!WARNING]
> The directory `lib/infraestructure/` uses the Spanish spelling of "infrastructure" (without the first 'r').  
> Match this spelling exactly in all imports and new file paths.

---

## 11. Code Style & Contribution Rules

1. **Git** create a new branch for each feature and commit with a descriptive message.
2. **Follow Clean Architecture** — respect the layer boundaries in §4.1.
3. **No hardcoded strings** — use `S.of(context)` or `S.current`.
4. **No hardcoded colors or sizes** — use the theme and layout constants.
5. **Riverpod only** for state — no `ChangeNotifier`, no `BLoC`, no raw `setState` unless purely local.
6. **Injectable** for all services, repositories, and use cases.
7. **Test use cases** — every use case should have a corresponding `mocktail`-based unit test in `test/`.
8. **Run `build_runner`** after modifying any `@injectable` / `@lazySingleton` annotated class.
9. All monetary values are stored as `double`. Display should be formatted with `intl` `NumberFormat.currency`.

