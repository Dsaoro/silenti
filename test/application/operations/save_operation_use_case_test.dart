import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:silenti/application/operations/save_operation_use_case.dart';
import 'package:silenti/core/models/operation.dart';
import 'package:silenti/infraestructure/storage/operation_dao.dart';

class MockOperationDAO extends Mock implements OperationDAO {}

Operation _operation({int category = 1, double amount = 500}) {
  return Operation(
    id: 0,
    financialAsset: 1,
    amount: amount,
    date: DateTime(2026, 1, 1),
    description: 'test',
    category: category,
    type: Operation.income,
  );
}

void main() {
  group('validateOperationForSave', () {
    test('rejects category 0 (the "not selected" placeholder)', () {
      expect(validateOperationForSave(_operation(category: 0)), isNotNull);
    });

    test('rejects a non-positive amount', () {
      expect(validateOperationForSave(_operation(amount: 0)), isNotNull);
      expect(validateOperationForSave(_operation(amount: -10)), isNotNull);
    });

    test('accepts a valid operation', () {
      expect(validateOperationForSave(_operation()), isNull);
    });
  });

  group('SaveOperationUSeCase', () {
    late MockOperationDAO dao;
    late SaveOperationUSeCase useCase;

    setUpAll(() {
      registerFallbackValue(<String, dynamic>{});
    });

    setUp(() {
      dao = MockOperationDAO();
      useCase = SaveOperationUSeCase(dao: dao);
    });

    test('does not call the DAO when the operation is invalid', () async {
      final result = await useCase.execute(operation: _operation(category: 0));

      expect(result.status, isFalse);
      verifyNever(() => dao.insertOperation(any()));
    });

    test('inserts a valid operation and returns its new id', () async {
      when(() => dao.insertOperation(any())).thenAnswer((_) async => 5);

      final result = await useCase.execute(operation: _operation());

      expect(result.status, isTrue);
      expect(result.model, 5);
    });
  });
}
