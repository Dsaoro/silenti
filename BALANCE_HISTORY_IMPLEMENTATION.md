# Sistema de Historial de Balances - Implementación

## Resumen
Se ha implementado un sistema completo de historial de balances que registra automáticamente cada cambio en los balances de los activos financieros cuando se realizan transacciones (ingresos/gastos). Este sistema permite generar gráficas históricas del balance de cada cuenta y del balance total.

## Componentes Implementados

### 1. Modelo de Datos
- **`BalanceHistory`** (`lib/core/models/balance_history.dart`):
  - Modelo que representa un punto en el historial de balance
  - Incluye referencia al activo financiero, balance, fecha y operación asociada
  - Método `daysSinceEpoch` para compatibilidad con fl_chart

### 2. Capa de Datos
- **`BalanceHistoryDAO`** (`lib/infraestructure/storage/balance_history_dao.dart`):
  - CRUD completo para el historial de balances
  - Métodos optimizados para gráficas (`getChartDataForAsset`)
  - Consultas para obtener últimos balances por activo
  - Muestreo inteligente para limitar puntos en gráficas

- **Tabla `balance_history`**:
  ```sql
  CREATE TABLE balance_history (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    financialAssetId INTEGER NOT NULL,
    balance REAL NOT NULL,
    date TEXT NOT NULL,
    operationId INTEGER,
    FOREIGN KEY (financialAssetId) REFERENCES financial_assets(id),
    FOREIGN KEY (operationId) REFERENCES operations(id)
  )
  ```

### 3. Lógica de Negocio
- **`GetAssetChartDataUseCase`** (`lib/application/financial_assets/get_asset_chart_data_use_case.dart`):
  - Obtiene datos de gráfica para un activo específico
  - Soporte para filtros por fecha y períodos predefinidos
  - Convierte datos a formato `FlSpot` para fl_chart

- **`GetTotalBalanceChartDataUseCase`** (`lib/application/financial_assets/get_total_balance_chart_data_use_case.dart`):
  - Obtiene datos de gráfica del balance total de todos los activos
  - Agregación automática de balances por fecha

- **`MigrateDatabaseUseCase`** (`lib/application/storage/migrate_database_use_case.dart`):
  - Migración automática para usuarios existentes
  - Crea tabla de historial y registros iniciales

### 4. Integración con Transacciones
- **Modificación de `FinancialAssetsDao`**:
  - Los métodos `deposit()` y `withdraw()` ahora registran automáticamente el historial
  - Cada cambio de balance queda vinculado a la operación que lo causó

- **Actualización de casos de uso**:
  - `DepositInFinancialAssetUseCase` y `WithdrawFromFinancialAssetUseCase` 
  - Ahora guardan primero la operación y luego usan su ID para el historial

### 5. Interfaz de Usuario
- **`CardGraphItem`** actualizado:
  - Soporte para datos reales en lugar de datos estáticos
  - Manejo de estados de carga y datos vacíos
  - Escalado automático de ejes Y

- **Páginas actualizadas**:
  - `AssetsPage`: Muestra gráfica del balance del activo seleccionado
  - `HomePageContent`: Muestra gráfica del balance total en el resumen

## Flujo de Funcionamiento

### Registro de Transacciones
1. Usuario registra ingreso/gasto → `Operation` creada
2. `SaveOperationUSeCase` guarda la operación → retorna ID
3. `DepositInFinancialAssetUseCase`/`WithdrawFromFinancialAssetUseCase` ejecuta
4. `FinancialAssetsDao.deposit()`/`withdraw()` actualiza balance
5. Se crea automáticamente registro en `BalanceHistory` con:
   - ID del activo financiero
   - Nuevo balance
   - Fecha actual
   - ID de la operación

### Visualización de Gráficas
1. Página solicita datos de gráfica
2. `GetAssetChartDataUseCase` obtiene historial del activo
3. Datos se convierten a `FlSpot` para fl_chart
4. `CardGraphItem` renderiza la gráfica con datos reales

## Características Técnicas

### Optimizaciones
- **Muestreo inteligente**: Limita puntos en gráficas (máximo 50 por defecto)
- **Consultas eficientes**: Uso de índices y agregaciones SQL
- **Carga bajo demanda**: Los datos se cargan solo cuando se necesitan

### Períodos Soportados
- Semana (7 días)
- Mes (30 días)
- 3 meses
- 6 meses  
- Año
- Todo el historial

### Migración Automática
- Detecta si la tabla `balance_history` existe
- Crea tabla y registros iniciales para usuarios existentes
- Ejecuta automáticamente al abrir la aplicación

## Uso en el Código

### Obtener datos de gráfica para un activo
```dart
GetAssetChartDataUseCase useCase = GetAssetChartDataUseCase();
var result = await useCase.executeByPeriod(
  financialAssetId: assetId,
  period: ChartPeriod.month,
);
List<FlSpot> chartData = result.model;
```

### Mostrar gráfica con datos reales
```dart
CardGraphItem(
  isLoading: false,
  title: "Balance History",
  chartData: chartData,
  showGrid: true,
  showTitles: true,
)
```

## Beneficios

1. **Trazabilidad completa**: Cada cambio de balance queda registrado
2. **Visualización histórica**: Gráficas que muestran evolución real
3. **Rendimiento optimizado**: Consultas eficientes y muestreo inteligente
4. **Migración transparente**: Funciona automáticamente para usuarios existentes
5. **Flexibilidad**: Soporte para múltiples períodos y filtros

## Estructura de Archivos Modificados/Creados

```
lib/
├── core/models/
│   └── balance_history.dart                    [NUEVO]
├── infraestructure/storage/
│   ├── balance_history_dao.dart               [NUEVO]
│   ├── financial_assets_dao.dart              [MODIFICADO]
│   └── secure_database_helper_pc.dart         [MODIFICADO]
├── application/
│   ├── financial_assets/
│   │   ├── get_asset_chart_data_use_case.dart [NUEVO]
│   │   ├── get_total_balance_chart_data_use_case.dart [NUEVO]
│   │   ├── deposit_in_financial_asset_use_case.dart [MODIFICADO]
│   │   └── withdraw_from_financial_asset_use_case.dart [MODIFICADO]
│   ├── operations/
│   │   └── save_operation_use_case.dart       [MODIFICADO]
│   └── storage/
│       └── migrate_database_use_case.dart     [NUEVO]
└── presentation/
    ├── components/
    │   └── card_graph_item.dart               [MODIFICADO]
    ├── assets_page.dart                       [MODIFICADO]
    ├── home_page_content.dart                 [MODIFICADO]
    └── home_page.dart                         [MODIFICADO]
```

Este sistema proporciona una base sólida para el seguimiento histórico de balances y su visualización en gráficas interactivas. 