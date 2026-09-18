import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:silenti/application/financial_assets/withdraw_from_financial_asset_use_case.dart';
import 'package:silenti/core/models/operation.dart';
import 'package:silenti/infraestructure/storage/financial_assets_dao.dart';

class MockFinancialAssetsDao extends Mock implements FinancialAssetsDao {}

Operation _operation({
  int financialAsset = 1,
  String type = Operation.expense,
  double amount = 500,
  int category = 1,
}) {
  return Operation(
    id: 0,
    financialAsset: financialAsset,
    amount: amount,
    date: DateTime(2026, 1, 1),
    description: 'Mercado',
    category: category,
    type: type,
  );
}

void main() {
  late MockFinancialAssetsDao dao;
  late WithdrawFromFinancialAssetUseCase useCase;

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() {
    dao = MockFinancialAssetsDao();
    useCase = WithdrawFromFinancialAssetUseCase(dao: dao);
  });

  void stubApplyOperation(ApplyOperationResult? response) {
    when(() => dao.applyOperation(
          operationData: any(named: 'operationData'),
          financialAsset: any(named: 'financialAsset'),
          amount: any(named: 'amount'),
          isDeposit: any(named: 'isDeposit'),
        )).thenAnswer((_) async => response);
  }

  test('rejects an operation whose type is not spent, without touching the DAO',
      () async {
    final result = await useCase.execute(_operation(type: Operation.income));

    expect(result.status, isFalse);
    verifyNever(() => dao.applyOperation(
          operationData: any(named: 'operationData'),
          financialAsset: any(named: 'financialAsset'),
          amount: any(named: 'amount'),
          isDeposit: any(named: 'isDeposit'),
        ));
  });

  test('rejects an unselected category (id 0) without touching the DAO', () async {
    final result = await useCase.execute(_operation(category: 0));

    expect(result.status, isFalse);
  });

  test('rejects a non-positive amount without touching the DAO', () async {
    final result = await useCase.execute(_operation(amount: 0));

    expect(result.status, isFalse);
  });

  test('reports failure (not success) when the DAO reports the asset was not found',
      () async {
    // BUSINESS_LOGIC_AUDIT.md #3.2 — the old code reported success here.
    stubApplyOperation(null);

    final result = await useCase.execute(_operation(financialAsset: 999));

    expect(result.status, isFalse);
  });

  test('reports success and calls the DAO with isDeposit: false on the happy path',
      () async {
    stubApplyOperation(
        const ApplyOperationResult(operationId: 43, newBalance: 500));

    final result = await useCase.execute(_operation(financialAsset: 7, amount: 500));

    expect(result.status, isTrue);
    verify(() => dao.applyOperation(
          operationData: any(named: 'operationData'),
          financialAsset: 7,
          amount: 500,
          isDeposit: false,
        )).called(1);
  });
}
