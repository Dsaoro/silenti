import 'package:silenti/application/shared/base_use_case.dart';
import 'package:silenti/application/shared/handle_result.dart';
import 'package:silenti/core/models/operation.dart';
import 'package:silenti/infraestructure/storage/operation_dao.dart';

class OperationRegistrationUseCase extends BaseUseCase {
  OperationRegistrationUseCase() : super('OperationRegistration');
  Future<HandleResult<bool>> execute({required Operation operation}) async {
    HandleResult<bool> result = HandleResult<bool>();
    final dao = OperationDAO();
    var operationStatus = await dao.insertOperation({
      'monto': operation.amount,
      'fecha': operation.date,
      'descripcion': operation.description,
      'categoria': operation.category,
      'tipo': operation.type
    });
    if (operationStatus != 0) {
      result.setData(true);
    } else {
      result.message = "error in Operation"; // TODO return a useful message
    }
    return result;
  }
}
