# Plan de trabajo — Alinear el código con el PRD y cubrirlo con pruebas

Este plan traduce `BUSINESS_LOGIC_AUDIT.md` (qué está roto) y `PRD.md`
(qué debe pasar en el MVP) en una secuencia de trabajo ejecutable, con
pruebas unitarias como parte de cada tarea, no como una fase aparte al
final. Cada ítem trae: qué corrige/agrega, dónde, y qué prueba lo respalda.

No se ha escrito ni cambiado código todavía — esto es la planificación.
Sugiero ejecutar Fase 0 primero y confirmar contigo antes de seguir, porque
cambia un patrón que hoy se repite en ~20 archivos (ver §0.2).

## Principio de secuenciación

1. Primero la base de pruebas (Fase 0) — sin ella, cada fix posterior se
   valida "a ojo" corriendo la app, que es exactamente cómo llegaron los
   bugs de la auditoría a producción.
2. Luego los hallazgos que el propio PRD marca como bloqueantes del MVP
   (§10 de `PRD.md`) — en el orden de mayor a menor daño a la confianza del
   usuario en sus datos (dinero mal contado > UX incorrecta > deuda
   técnica).
3. Luego las historias del PRD que son trabajo nuevo, no un fix (categorías
   de ingreso reales, snapshot mensual, planeador con vista de timeline).
4. Al final, la limpieza no bloqueante (§10 de `PRD.md` la marca
   explícitamente como "no bloquea el MVP").

Cada tarea de fix trae **Antes/Después esperado** para que sirva como
criterio de aceptación, y **Test** para que quede escrito qué prueba lo
demuestra.

---

## Fase 0 — Fundaciones de testing ✅ Ejecutada

**Estado:** implementada en el código (ver commit de esta fase). **Nota
importante:** este entorno no tiene el SDK de Flutter/Dart instalado, así que
`flutter test`/`flutter analyze` no se pudieron ejecutar aquí — el código se
revisó manualmente (releído cada archivo tras editarlo, más una verificación
de balance de `{}`/`()` en todos los archivos tocados) pero **falta correr la
suite real antes de confiar en que compila y pasa**. Corran `flutter pub get
&& flutter test` (o su CI) como primer paso antes de seguir con la Fase 1.

**Ajuste de alcance respecto al plan original:** §0.2 solo hablaba de
inyectar el DAO en los *casos de uso*. En la práctica, para que los tests de
DAO de §0.1 pudieran usar la base de datos en memoria en vez del singleton
real (`SecureDatabaseHelperPC`), los **8 DAOs también necesitaron el mismo
patrón** (`Future<Database> Function()? databaseProvider` opcional). Sin
esto, un test de DAO habría llamado a `path_provider` de verdad y fallado en
`flutter_test`. Se aplicó el mismo patrón mecánico, con el mismo argumento de
"no rompe ningún call site existente" (todos usan el constructor sin
argumentos).

**Archivos nuevos:**
- `lib/infraestructure/adapters/silenti_schema.dart` — DDL/seed extraídos de
  `secure_database_helper_pc.dart` (que ahora solo los invoca).
- `test/helpers/test_database.dart` — abre una DB en memoria con el mismo
  schema, `singleInstance: false` para que cada test tenga su propia
  instancia aislada aunque compartan el path `:memory:`.
- `test/core/models/*_test.dart` — pruebas de entidad para `FinancialAsset`
  (`BankAccount`/`InvestmentAsset`), `Operation`, `BudgetCategory`,
  `BalanceHistory`, `User` (puro Dart, sin DB).
- `test/infraestructure/storage/financial_assets_dao_test.dart` — prueba de
  concepto de un test de DAO contra la DB en memoria real (incluye un test
  que documenta explícitamente el comportamiento actual sin guardia de
  sobregiro, `BUSINESS_LOGIC_AUDIT.md` §3.4).
- `test/application/financial_assets/deposit_in_financial_asset_use_case_test.dart`
  — prueba de concepto de un test de caso de uso con `mocktail`, cubriendo
  solo comportamiento ya correcto hoy (rechazo de tipo inválido, camino
  feliz) — deliberadamente **no** cubre el bug de §3.2 (falso éxito si el
  activo no existe); esa prueba se agrega junto con su fix en la Fase 1.1,
  no antes.

Las pruebas de DAO/caso de uso **restantes** de la tabla de cobertura (al
final de este documento) se escriben junto con cada fix de la Fase 1, no
todas de una vez aquí — Fase 0 solo prueba que la infraestructura funciona.

Sin esto, "generar pruebas unitarias para cada entidad y transacción" no es
posible de forma aislada, porque hoy cada caso de uso instancia su propio
DAO (`BUSINESS_LOGIC_AUDIT.md` §4.2) y no hay forma de inyectar un doble de
prueba, ni una base de datos de prueba reutilizable.

### 0.1 Base de datos SQLite en memoria para tests
- Extraer las sentencias DDL de `SecureDatabaseHelperPC._initDB()`
  (`lib/infraestructure/adapters/secure_database_helper_pc.dart`) a una
  función pura reutilizable (ej. `SilentiSchema.createAll(Database db)`),
  sin tocar su comportamiento en producción.
- Crear `test/helpers/test_database.dart`: abre una DB con
  `databaseFactoryFfi` en `inMemoryDatabasePath`, aplica
  `SilentiSchema.createAll`, y la retorna limpia para cada test
  (`setUp`/`tearDown`).
- **Por qué en memoria y no mocks para los DAOs:** los DAOs son SQL crudo;
  mockearlos solo probaría que el mock devuelve lo que le dijimos, no que el
  SQL es correcto. Una DB real en memoria detecta errores de SQL de verdad
  (por eso el bug de §3.6, con el `GROUP BY` que devuelve lista vacía, se
  habría visto en un test así).

### 0.2 Hacer los casos de uso testeables (inyección mínima, sin paquetes nuevos)
- Cambiar cada `UseCase` para recibir su(s) DAO(s) como parámetro de
  constructor **opcional** con valor por defecto, ej.:
  ```dart
  class DeleteBudgetCategoryUseCase extends BaseUseCase {
    final BudgetCategoriesDAO dao;
    DeleteBudgetCategoryUseCase({BudgetCategoriesDAO? dao})
        : dao = dao ?? BudgetCategoriesDAO(),
          super("DeleteBudgetCategory");
    ...
  }
  ```
  Esto no introduce `injectable`/`get_it` (`CLAUDE.md` es explícito en no
  mezclar eso a mitad de archivo) — es un cambio mecánico, uniforme, en
  todos los `application/*use_case.dart`. Cada llamado existente en
  `presentation/` (`XxxUseCase().execute(...)`) sigue funcionando sin
  cambios porque el parámetro es opcional.
- Con esto, un test de caso de uso puede pasar un `MockXxxDao()`
  (`mocktail`, ya está en `pubspec.yaml`) para probar la lógica del caso de
  uso aislada de la base de datos real (ej. probar que
  `DepositInFinancialAssetUseCase` falla si el DAO devuelve `[]`, sin
  necesitar una DB real para ese caso).

### 0.3 Estructura de carpetas de test
```
test/
├── helpers/test_database.dart
├── core/models/            # 1 archivo por entidad, sin DB
├── infraestructure/storage/  # 1 archivo por DAO, contra DB en memoria
└── application/            # 1 archivo por caso de uso, con mocktail
```

**Sin esto no se puede empezar la Fase 1 con pruebas reales** — es la única
tarea que bloquea a todas las demás.

---

## Fase 1 — Corregir los hallazgos que el PRD marca como bloqueantes del MVP ✅ Ejecutada

**Estado:** los 8 ítems (1.1–1.8) están implementados con sus pruebas. Igual
que en la Fase 0, este entorno no tiene el SDK de Flutter, así que no pude
correr `flutter test` — verificación manual (relectura de cada archivo tras
editarlo + balance de `{}`/`()` en todo lo tocado). **Corran `flutter pub get
&& flutter test` antes de dar esto por bueno.**

**Cambios de diseño respecto al plan original:**
- **1.1 y 1.2 se implementaron juntos.** El plan sugería una `db.transaction()`
  dentro de `FinancialAssetsDao` como una opción; se tomó esa opción:
  `FinancialAssetsDao.applyOperation(...)` reemplaza por completo a los
  antiguos `deposit()`/`withdraw()`, insertando la `Operation`, actualizando
  el saldo y escribiendo `balance_history` dentro de una sola
  `db.transaction()`, devolviendo `null` (sin escribir nada) si el activo no
  existe. `DepositInFinancialAssetUseCase`/`WithdrawFromFinancialAssetUseCase`
  ya no llaman a `SaveOperationUSeCase` (no puede participar en la misma
  transacción) — la llaman directo. **`SaveOperationUSeCase` queda sin
  ningún llamador en el flujo real** (antes solo lo usaban estos dos casos de
  uso); se conserva porque sigue siendo una unidad correcta y con test, pero
  es candidata a revisar en Fase 3 (¿se elimina o se le da un uso real?).
- **1.8 se resolvió con una función compartida** `validateOperationForSave()`
  en `save_operation_use_case.dart`, usada por `SaveOperationUSeCase` y por
  los dos casos de uso de depósito/retiro (ya que estos dejaron de pasar por
  `SaveOperationUSeCase`, ver punto anterior).
- **1.4 necesitó un selector Gasto/Ingreso en `budget_page.dart`** (no
  existía ninguna pestaña ni toggle) — se agregó como dos botones simples
  (`_buildTypeToggle()`), no un `TabBar` nuevo, para no rehacer el layout de
  3 pestañas ya existente en esa pantalla.
- **1.4 reveló un bug adicional no listado en el audit**: en
  `income_form.dart`, el dropdown de categoría estaba enlazado a la variable
  `subCategory` (nunca usada al guardar) en vez de `category` — el usuario
  podía "elegir" una categoría en la UI y la operación se guardaba siempre
  con el valor por defecto (`category = 1`). Se corrigió al mismo tiempo que
  se cambió la fuente de datos a `GetIncomeCategoriesUseCase`, porque no
  tenía sentido cablear el dropdown correcto hacia datos de ingreso reales
  sin arreglar a qué variable apunta.
- **1.5**: se asumió que el proyecto no tiene usuarios reales con datos en
  `spend_sub_categories` que preservar (no se recibió respuesta a la
  pregunta abierta del plan) — se retiró la tabla del `onCreate` para bases
  nuevas, pero **no se agregó una migración que la elimine en instalaciones
  existentes** (quedaría como tabla huérfana, inofensiva). Avisar si esto es
  incorrecto.
- **1.5 también corrige** que `Operation.category` ahora guarda el id de la
  subcategoría (no el de la categoría padre) cuando el usuario selecciona
  una en `spend_form.dart` — antes era imposible que apuntara ahí porque las
  subcategorías vivían en una tabla/espacio de ids completamente distinto.

**Hallazgo nuevo, fuera de alcance de estos 8 ítems (no corregido):** en
`budget_page.dart`, el formulario de edición de una categoría de
**primer nivel** (`_buildDetailsTable()`) tiene el mismo problema que tenía
`assets_page.dart` antes de 1.7 — su `BudgetForm.onSave` solo hace un
`print()` de depuración, nunca llama a `UpdateBudgetCategoryUseCase` (la
edición de **subcategorías**, vía `_showEditSubcategoryDialog`, sí funciona).
No estaba en la lista de 8 hallazgos de la auditoría original ni en el
alcance de esta fase — queda para decidir si entra en un Fase 1.9 o en el
backlog de Fase 3.

Cada uno de los 8 ítems originales cita el hallazgo de
`BUSINESS_LOGIC_AUDIT.md` y la historia de `PRD.md` que depende de él.

### 1.1 Deposit/Withdraw no deben reportar éxito si el activo no existe
**Corrige:** §3.2 · **Historia:** H2.2
- `DepositInFinancialAssetUseCase`/`WithdrawFromFinancialAssetUseCase`
  deben inspeccionar el resultado de
  `FinancialAssetsDao.deposit()`/`.withdraw()` y llamar `result.setError(...)`
  si viene vacío, en vez de `result.setData(true)` incondicional.
- **Antes:** operar sobre un `financialAsset` inexistente inserta la
  `Operation` y reporta éxito. **Después:** reporta error y (ver 1.2) no
  deja la `Operation` huérfana.
- **Test:** `application/deposit_in_financial_asset_use_case_test.dart` —
  con un `MockFinancialAssetsDao` que devuelve `[]`, `execute()` debe
  retornar `status == false`.

### 1.2 Atomicidad del flujo de dinero (insertar operación + actualizar saldo + historial)
**Corrige:** §3.3 · **Historia:** H2.2
- Envolver los 3 pasos en una única `db.transaction()` dentro de
  `FinancialAssetsDao` (recibiendo el insert de la operación también dentro
  de la transacción, lo que implica mover `SaveOperationUSeCase`'s DAO call
  al mismo alcance transaccional, o exponer un método de DAO compuesto
  `registerOperationAndUpdateBalance(...)`).
- **Antes:** 3 escrituras independientes; una falla a mitad dejaba estado
  parcial. **Después:** o se aplican las 3 o ninguna.
- **Test:** `infraestructure/financial_assets_dao_test.dart` contra la DB en
  memoria — forzar una excepción (ej. financialAsset inexistente) y verificar
  que **no** quedó una fila en `Operations` ni en `balance_history`.

### 1.3 Eliminar categoría de presupuesto debe funcionar de verdad
**Corrige:** §3.1 · **Historia:** H1.1
- Implementar `DeleteBudgetCategoryUseCase.execute()` llamando a un nuevo
  `BudgetCategoriesDAO.deleteBudgetCategory(id)` (no existe hoy, hay que
  agregarlo).
- Decidir y aplicar la regla de H1.1: si la categoría tiene subcategorías o
  `Operations` asociadas, no se borra en silencio — se avisa/pide
  confirmación explícita (a definir el mecanismo exacto: bloquear el borrado
  o reasignar a un padre nulo; sugiero bloquear para el MVP, es lo más
  simple y seguro).
- **Test:** borrar una categoría sin operaciones asociadas la elimina;
  borrar una con operaciones asociadas retorna error y no la elimina.

### 1.4 Categorías de ingreso reales (no las de gasto)
**Corrige:** §3.5 · **Historia:** H1.3, H2.1
- Nuevo `GetIncomeCategoriesUseCase.execute()` (reemplaza el stub
  `GetIncomeTypesUseCase`) que llama a
  `BudgetCategoriesDAO.getBudgetIncomes()` (ya existe, hoy sin uso).
  `AddBudgetCategoryUseCase`/`UpdateBudgetCategoryUseCase` no cambian —
  ya aceptan `type`.
- `budget_page.dart` deja de hardcodear `type: CategoryType.spent`
  (líneas 170 y 397 según la auditoría) — necesita un selector de tipo o
  una pestaña Ingreso/Gasto.
- `income_form.dart` cambia su `_getCategories()` para llamar
  `GetIncomeCategoriesUseCase` en vez de `GetExpensesCategoriesUseCase`.
- **Test:** `GetIncomeCategoriesUseCase` retorna solo categorías
  `type == 'income'` contra la DB en memoria sembrada con ambos tipos.

### 1.5 Unificar el árbol de subcategorías en `BudgetCategory.parentId` (2 niveles)
**Corrige:** §3.8, §3.9 · **Historia:** H1.2 (decisión ya tomada en el PRD)
- Retirar `SpendSubCategories`, `SpendSubCategoriesDao`,
  `GetExpensesSubCategoriesUseCase` y la tabla `spend_sub_categories`
  (con su propia migración de baja si hay datos existentes que preservar —
  a decidir si aplica dado que el proyecto no está en producción todavía).
  Si el proyecto **ya** tiene datos reales de usuarios que no se pueden
  perder, avísame antes de este paso — cambia el plan de migración.
- `spend_form.dart` deja de usar `GetExpensesSubCategoriesUseCase().byId(...)`
  y en su lugar pide los hijos de la categoría seleccionada dentro del
  mismo árbol que ya construye `GetExpensesCategoriesUseCase`.
- `GetExpensesCategoriesUseCase` (y su análogo de ingresos, 1.4) deben
  rechazar explícitamente un tercer nivel al construir el árbol (hoy lo
  trunca en silencio — con la unificación pasa a ser una regla explícita,
  no un bug accidental).
- **Test:** construir el árbol con 3 niveles sembrados en la DB de prueba y
  verificar que el tercer nivel no aparece (comportamiento esperado, ahora
  documentado) + test de que hijo/nieto conservan `totalAmount` correcto
  para los 2 niveles soportados.

### 1.6 Resultado vacío ≠ error
**Corrige:** §3.6 · **Historia:** H1.5, H2.3
- En `GetOperations` (las 4 variantes) y `GetSpendsThisMonthUseCase`,
  cambiar la condición de éxito: una lista vacía es
  `result.setData([])`/`result.setData(0.0)`, nunca `setError`.
- Arreglar `OperationDAO.getSpendByMonth()` para que devuelva `0` en vez de
  una lista vacía cuando no hay operaciones ese mes (ej. `SELECT
  COALESCE(SUM(amount),0)` sin `GROUP BY`, ya que solo se necesita un total).
- **Test:** con la DB de prueba vacía (mes sin operaciones),
  `GetSpendsThisMonthUseCase().execute()` retorna `status == true, model ==
  0.0` — hoy lanzaría `StateError` internamente.

### 1.7 Editar un activo financiero existente
**Corrige:** §3.7 · **Historia:** H2.4
- Implementar `FinancialAssetsUpdateUseCase.execute(FinancialAsset asset)`
  llamando a `FinancialAssetsDao.updateAccountById(asset.id, asset.toMap())`
  (el DAO ya existe, solo falta el caso de uso y el cableado).
- `assets_page.dart` ya tiene un flag `_isEditing` sin usar para esto —
  conectar el botón/flujo de edición del `AssetForm` a este caso de uso en
  vez de a `CreateFinancialAssetUseCase`.
- **Test:** editar nombre/balance de un activo sembrado en la DB de prueba y
  verificar que persiste.

### 1.8 Validar categoría y monto antes de guardar una operación
**Corrige:** §4.4 · **Historia:** H1.4/H2.1 (validación implícita)
- `SaveOperationUSeCase.execute()` rechaza `category <= 0` (placeholder "sin
  seleccionar") y `amount <= 0` antes de llamar al DAO, retornando un
  `HandleResult` de error claro.
- **Test:** `category: 0` o `amount: 0` retornan error sin tocar la DB.

---

## Fase 2 — Trabajo nuevo del PRD (no son fixes, son historias sin construir aún)

### 2.1 Vista de presupuesto vs. ingreso proyectado (déficit informativo)
**Historia:** H1.4
- Nuevo `GetBudgetSummaryUseCase` que suma total de categorías `income` vs.
  total de categorías `spent` (raíz, sin duplicar por subcategoría) y
  retorna ambos totales + la diferencia.
- UI en `budget_page.dart`/`home_page_content.dart` que muestra la
  diferencia, en rojo si es negativa — sin bloquear guardar (decisión ya
  tomada en el PRD §5).
- **Test:** con ingresos y gastos sembrados, el total y el signo del
  déficit son correctos.

### 2.2 Snapshot mensual del presupuesto (recurrencia con historial)
**Historia:** H1.6
- **Necesita una decisión de diseño antes de estimar el esfuerzo:** hoy
  `BudgetCategory` no tiene noción de "mes". Propuesta mínima: una tabla
  `budget_category_snapshot(categoryId, year, month, amount)` que se escribe
  la primera vez que se lee/edita el presupuesto de un mes nuevo, capturando
  el monto vigente en ese momento; los meses pasados se leen del snapshot,
  el mes actual y futuro del valor vivo en `budget_categories`.
- **Test:** cambiar el monto de una categoría a mitad de mes no debe alterar
  el snapshot de meses anteriores ya creado.

### 2.3 Planeador de gastos periódicos (timeline + notificación push)
**Historia:** H3.1–H3.4 — la pieza más grande de trabajo nuevo, con la única
dependencia externa nueva del MVP.
- Modelo nuevo `ScheduledExpense` (`core/models`): categoría, nombre, día de
  vencimiento del mes, días de aviso previo, activo/inactivo. Se puede
  reconstruir sobre la tabla `notifications` ya existente (hoy muerta,
  `BUSINESS_LOGIC_AUDIT.md` §3.11) en vez de crear una tabla nueva, si su
  forma se ajusta razonablemente — a validar en el diseño detallado.
- DAO + caso de uso CRUD, siguiendo el patrón existente.
- Vista de timeline de vencimientos del mes en `presentation/` (pantalla
  nueva) — H3.2 ya no pide un calendario tipo grilla, sino una lista
  cronológica de próximos vencimientos.
- Integración de `flutter_local_notifications` (dependencia nueva en
  `pubspec.yaml`) + permisos de notificación en Android
  (`AndroidManifest.xml`) + programación de la notificación al crear/editar
  un `ScheduledExpense`.
- **Test (lo que sí es unitario):** cálculo de "próxima fecha de
  vencimiento" y "fecha en la que debe dispararse el aviso" dado un día del
  mes y un plazo de aviso — pura lógica de fechas, sin DB ni plugin.
- **No es unitario, requiere QA manual:** que la notificación realmente
  llegue del sistema operativo con la app cerrada. Se documenta como caso
  de prueba manual en el checklist de release, no como test automatizado.

---

## Fase 3 — Limpieza técnica no bloqueante (backlog post-MVP)

Confirmado en `PRD.md` §10 que ninguno de estos bloquea el release. Se listan
para no perderlos:

- §3.10 — Eliminar `OperationRegistrationUseCase` (dead code, claves en
  español que no calzan con el esquema).
- §3.11 — Decidir si `profits`/`ProfitsDAO` se eliminan del todo (si no se
  retoma la valuación de inversiones pronto) o se dejan documentados como
  reservados para esa fase futura.
- §3.12 — Parametrizar el `amount` en `FinancialAssetsDao.deposit/withdraw`
  en vez de interpolarlo en el SQL.
- §4.3 — `Frequency.label` en `core/models/financial_asset.dart` depende de
  `generated/l10n.dart`; decidir si se mueve la traducción a la capa de
  presentación o se acepta como excepción documentada a la regla de capas.
- Revisar `agents.md`: sigue describiendo Riverpod/injectable/get_it/AES
  como si estuvieran implementados. Con el plan de arriba (0.2) decidiendo
  explícitamente **no** adoptar esos paquetes para el MVP, `agents.md`
  debería actualizarse para no seguir prometiendo una arquitectura que no se
  va a construir en este ciclo — o, si sí se quiere adoptar más adelante,
  marcarlo con fecha/fase.

---

## Cobertura de pruebas unitarias — entidades y transacciones (resumen)

| Capa | Archivo(s) | Qué se prueba | Depende de |
|---|---|---|---|
| Entidades (`core/models`) | `financial_asset_test.dart` | `BankAccount`/`InvestmentAsset` `toMap`/`fromMap`, `currentBalance` (incl. `quantity * currentPrice`), `Frequency.fromString` con valor inválido | nada (Dart puro) |
| | `operation_test.dart` | `fromJson`/`fromMap`/`toMap` simétricos, constantes `income`/`expense` | nada |
| | `budget_category_test.dart` | `totalAmount` recursivo, `copyWith`, `fromMap` con `subcategories: []` | nada |
| | `balance_history_test.dart` | `fromMap`/`toMap`, `daysSinceEpoch` | nada |
| | `user_test.dart` | `fromMap` con `mode_group` vs `group` (fallback), `toMap` | nada |
| DAOs (`infraestructure/storage`) | uno por DAO | cada método CRUD contra la DB en memoria; casos límite (activo inexistente, mes sin operaciones, tabla vacía) | Fase 0.1 |
| Casos de uso — transacciones | `save_operation_use_case_test.dart`, `deposit_..._test.dart`, `withdraw_..._test.dart` | ruta feliz, activo inexistente → error (1.1), categoría/monto inválido → error (1.8), atomicidad (1.2) | Fase 0.2 |
| Casos de uso — presupuesto | `add/update/delete_budget_category_use_case_test.dart`, `get_expenses/income_categories_use_case_test.dart` | delete real (1.3), árbol de 2 niveles (1.5), filtro por tipo (1.4) | Fase 0.1/0.2 |
| Casos de uso — reportes | `get_operations_use_case_test.dart`, `get_spends_this_month_use_case_test.dart`, `get_budget_summary_use_case_test.dart` | vacío ≠ error (1.6), suma de déficit (2.1) | Fase 0.1/0.2 |

Con esta tabla ejecutada completa, `flutter test` se convierte en el mismo
checklist de "¿el MVP está listo?" que ya propone `PRD.md` §10, pero
automatizado en vez de manual.

---

## Siguiente paso

Antes de tocar código, confirmo contigo:
1. ¿Arranco por la Fase 0 (fundaciones de testing) tal como está descrita —
   en particular el cambio de constructor opcional en cada caso de uso
   (§0.2), que toca ~20 archivos aunque no cambia su comportamiento externo?
2. Para 1.5 (unificar subcategorías): ¿hay datos reales de usuarios ya en
   producción que debamos migrar, o el proyecto todavía no tiene usuarios y
   puedo simplemente retirar `SpendSubCategories`?
3. Para 2.3 (planeador): ¿confirmas que `flutter_local_notifications` es la
   dependencia aceptable, o prefieres que investigue alternativas antes de
   fijarla en el plan?
