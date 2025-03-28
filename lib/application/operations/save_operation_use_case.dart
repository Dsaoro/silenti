import 'package:silenti/application/shared/base_use_case.dart';
import 'package:silenti/application/shared/handle_result.dart';
import 'package:silenti/core/models/operation.dart';
import 'package:silenti/infraestructure/storage/operation_dao.dart';

class SaveOperationUSeCase extends BaseUseCase {
  SaveOperationUSeCase() : super('SaveOperation');
  Future<HandleResult<bool>> execute({required Operation operation}) async {
    HandleResult<bool> result = HandleResult<bool>();
    final dao = OperationDAO();
    var operationStatus = await dao.insertOperation(
      operation.toMap(),
    );
    if (operationStatus != 0) {
      result.setData(true);
    } else {
      result.message = "Operation could not be registered";
    }
    return result;
  }
}
