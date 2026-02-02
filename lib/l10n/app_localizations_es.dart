// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get transactionRegistration => 'Registrar transacción';

  @override
  String get home => 'Inicio';

  @override
  String get income => 'Ingresos';

  @override
  String get spent => 'Gastos';

  @override
  String get operationRegistration => 'Registrar operación';

  @override
  String get depositRegistration => 'Registro de depósito';

  @override
  String get spendRegistration => 'Registro de gasto';

  @override
  String get withdrawalRegistration => 'Registro de retiro';

  @override
  String get amount => 'Monto';

  @override
  String get initialAmount => 'Monto inicial';

  @override
  String get accountBalance => 'Saldo de la cuenta';

  @override
  String get asset => 'Cuenta';

  @override
  String get budget => 'Presupuesto';

  @override
  String get accountName => 'Nombre de la cuenta';

  @override
  String get category => 'Categoría';

  @override
  String get register => 'Registrar';

  @override
  String get update => 'Actualizar';

  @override
  String get type => 'Tipo';

  @override
  String get date => 'Fecha';

  @override
  String get select => 'Seleccionar';

  @override
  String get description => 'Descripción';

  @override
  String get subCategory => 'Subcategoría';

  @override
  String get balance => 'Saldo';

  @override
  String get summary => 'Resumen';

  @override
  String get add => 'Agregar';

  @override
  String get delete => 'Eliminar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get operations => 'Operaciones';

  @override
  String get frequency => 'Frecuencia';

  @override
  String get frecDaily => 'Diario';

  @override
  String get frecWeekly => 'Semanal';

  @override
  String get frecSemiMonthly => 'Quincenal';

  @override
  String get frecMonthly => 'Mensual';

  @override
  String get frecAnnual => 'Anual';

  @override
  String get frecOnce => 'Una vez';

  @override
  String get itemsPerPage => 'Elementos por página';

  @override
  String get details => 'Detalles';

  @override
  String get interestRate => 'Tasa de interés (E.A.)';

  @override
  String get warning => 'Advertencia';

  @override
  String get monthlyBudget => 'Presupuesto mensual';

  @override
  String get budgetName => 'Nombre del presupuesto';

  @override
  String get newBudget => 'Nuevo presupuesto';

  @override
  String get status => 'Estado';

  @override
  String get unavailableData => 'Datos no disponibles';

  @override
  String get balanceIncluded => 'Mostrar en el saldo';

  @override
  String deleteWarning(Object item) {
    return 'Al eliminar $item se perderá toda la información almacenada. Esta acción es irreversible.\n¿Desea continuar?';
  }

  @override
  String get newAccount => 'Nueva cuenta';
}
