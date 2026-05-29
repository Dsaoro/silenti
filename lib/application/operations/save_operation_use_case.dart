import 'package:silenti/application/shared/base_use_case.dart';
import 'package:silenti/application/shared/handle_result.dart';
import 'package:silenti/core/models/operation.dart';
import 'package:silenti/infraestructure/storage/operation_dao.dart';

class SaveOperationUSeCase extends BaseUseCase {
  SaveOperationUSeCase() : super('SaveOperation');
  Future<HandleResult<int>> execute({required Operation operation}) async {
    HandleResult<int> result = HandleResult<int>();
    final dao = OperationDAO();
    var operationId = await dao.insertOperation(
      operation.toMap(),
    );
    if (operationId != 0) {
      result.setData(operationId);
    } else {
      result.setError("Operation could not be registered");
    }
    return result;
  }
}
