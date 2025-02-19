import 'package:silenti/application/shared/base_use_case.dart';
import 'package:silenti/application/shared/handle_result.dart';
import 'package:silenti/core/models/transaction.dart';
import 'package:silenti/infraestructure/storage/transaction_dao.dart';

class TransactionRegistrationUseCase extends BaseUseCase {
  TransactionRegistrationUseCase() : super('TransactionRegistration');
  Future<HandleResult<bool>> execute({required Transaction transaction}) async {
    HandleResult<bool> result = HandleResult<bool>();
    final dao = TransactionDAO();
    var operationStatus = await dao.insertTransaction({
      'monto': 50000,
      'fecha': '2025-02-10',
      'descripcion': 'Pago de factura',
      'categoria': 'Servicios',
      'tipo': 'gasto'
    });
    if (operationStatus != 0) {
      result.setData(true);
    } else {
      result.message = "error in transaction"; // TODO return a useful message
    }
    return result;
  }
}
