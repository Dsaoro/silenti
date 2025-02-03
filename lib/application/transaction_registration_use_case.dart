import 'package:silenti/application/shared/base_use_case.dart';
import 'package:silenti/application/shared/handle_result.dart';
import 'package:silenti/core/models/transaction.dart';

class TransactionRegistrationUseCase extends BaseUseCase {
  TransactionRegistrationUseCase() : super('TransactionRegistration');
  Future<HandleResult<bool>> execute({required Transaction income}) async {
    HandleResult<bool> result = HandleResult<bool>();
    return result;
  }
}
