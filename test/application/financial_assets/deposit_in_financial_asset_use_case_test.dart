import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:silenti/application/financial_assets/deposit_in_financial_asset_use_case.dart';
import 'package:silenti/application/operations/save_operation_use_case.dart';
import 'package:silenti/application/shared/handle_result.dart';
import 'package:silenti/core/models/operation.dart';
import 'package:silenti/infraestructure/storage/financial_assets_dao.dart';

class MockFinancialAssetsDao extends Mock implements FinancialAssetsDao {}

class MockSaveOperationUseCase extends Mock implements SaveOperationUSeCase {}

Operation _operation({int financialAsset = 1, String type = Operation.income}) {
  return Operation(
    id: 0,
    financialAsset: financialAsset,
    amount: 500,
    date: DateTime(2026, 1, 1),
    description: 'Salario',
    category: 1,
    type: type,
  );
}

void main() {
  late MockFinancialAssetsDao dao;
  late MockSaveOperationUseCase saveOperationUseCase;
  late DepositInFinancialAssetUseCase useCase;

  setUpAll(() {
    registerFallbackValue(_operation());
  });

  setUp(() {
    dao = MockFinancialAssetsDao();
    saveOperationUseCase = MockSaveOperationUseCase();
    useCase = DepositInFinancialAssetUseCase(
      dao: dao,
      saveOperationUseCase: saveOperationUseCase,
    );
  });

  test('rejects an operation whose type is not income, without touching collaborators',
      () async {
    final result = await useCase.execute(_operation(type: Operation.expense));

    expect(result.status, isFalse);
    verifyNever(
        () => saveOperationUseCase.execute(operation: any(named: 'operation')));
    verifyNever(() => dao.deposit(
          financialAsset: any(named: 'financialAsset'),
          amount: any(named: 'amount'),
          operationId: any(named: 'operationId'),
        ));
  });

  test('does not call the DAO if saving the operation fails', () async {
    final saveFailure = HandleResult<int>()..setError('boom');
    when(() => saveOperationUseCase.execute(operation: any(named: 'operation')))
        .thenAnswer((_) async => saveFailure);

    final result = await useCase.execute(_operation());

    expect(result.status, isFalse);
    verifyNever(() => dao.deposit(
          financialAsset: any(named: 'financialAsset'),
          amount: any(named: 'amount'),
          operationId: any(named: 'operationId'),
        ));
  });

  test('saves the operation, then deposits into the asset using its new operation id',
      () async {
    final saveSuccess = HandleResult<int>()..setData(42);
    when(() => saveOperationUseCase.execute(operation: any(named: 'operation')))
        .thenAnswer((_) async => saveSuccess);
    when(() => dao.deposit(
          financialAsset: any(named: 'financialAsset'),
          amount: any(named: 'amount'),
          operationId: any(named: 'operationId'),
        )).thenAnswer((_) async => [
          {'balance': 1500.0}
        ]);

    final result = await useCase.execute(_operation(financialAsset: 7));

    expect(result.status, isTrue);
    verify(() => dao.deposit(
          financialAsset: 7,
          amount: 500,
          operationId: 42,
        )).called(1);
  });
}
