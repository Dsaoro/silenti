import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:silenti/application/operations/get_operations_use_case.dart';
import 'package:silenti/infraestructure/storage/operation_dao.dart';

class MockOperationDAO extends Mock implements OperationDAO {}

void main() {
  late MockOperationDAO dao;
  late GetOperations useCase;

  setUp(() {
    dao = MockOperationDAO();
    useCase = GetOperations(dao: dao);
  });

  group('byFinancialAsset', () {
    test('an empty result is success with an empty list, not an error', () async {
      // BUSINESS_LOGIC_AUDIT.md #3.6 — a brand-new asset with zero
      // transactions is a normal state, not a failure.
      when(() => dao.getOperationsByAssetId(any())).thenAnswer((_) async => []);

      final result = await useCase.byFinancialAsset(1);

      expect(result.status, isTrue);
      expect(result.model, isEmpty);
    });

    test('a DAO exception is still reported as an error', () async {
      when(() => dao.getOperationsByAssetId(any())).thenThrow(Exception('db error'));

      final result = await useCase.byFinancialAsset(1);

      expect(result.status, isFalse);
    });
  });

  group('byFinancialAssetLimited', () {
    test('an empty result is success with an empty list', () async {
      when(() => dao.getOperationsByAssetIdLimited(any(), limit: any(named: 'limit')))
          .thenAnswer((_) async => []);

      final result = await useCase.byFinancialAssetLimited(1, limit: 6);

      expect(result.status, isTrue);
      expect(result.model, isEmpty);
    });
  });

  group('byBudgetCategoryLimited', () {
    test('an empty result is success with an empty list', () async {
      when(() => dao.getOperationsByBudgetCategoryLimited(any(),
              limit: any(named: 'limit')))
          .thenAnswer((_) async => []);

      final result = await useCase.byBudgetCategoryLimited(1, limit: 6);

      expect(result.status, isTrue);
      expect(result.model, isEmpty);
    });
  });

  group('getLastOperations', () {
    test('an empty result is success with an empty list', () async {
      when(() => dao.getOperationsLimited(limit: any(named: 'limit')))
          .thenAnswer((_) async => []);

      final result = await useCase.getLastOperations(limit: 10);

      expect(result.status, isTrue);
      expect(result.model, isEmpty);
    });
  });
}
