import 'package:flutter_test/flutter_test.dart';
import 'package:silenti/core/models/operation.dart';

void main() {
  group('Operation', () {
    test('income/expense constants match the DB CHECK constraint values', () {
      expect(Operation.income, 'income');
      expect(Operation.expense, 'spent');
    });

    test('toMap does not include id (autoincrement column)', () {
      final operation = Operation(
        id: 42,
        financialAsset: 1,
        amount: 1000,
        date: DateTime(2026, 1, 15),
        description: 'Salario',
        category: 2,
        type: Operation.income,
      );

      expect(operation.toMap().containsKey('id'), isFalse);
    });

    test('toMap/fromMap round-trip preserves every field', () {
      final operation = Operation(
        id: 0,
        financialAsset: 3,
        amount: 250.75,
        date: DateTime(2026, 3, 10, 8, 30),
        description: 'Mercado',
        category: 5,
        type: Operation.expense,
      );

      final map = operation.toMap()..['id'] = 9;
      final rebuilt = Operation.fromMap(map);

      expect(rebuilt.id, 9);
      expect(rebuilt.financialAsset, operation.financialAsset);
      expect(rebuilt.amount, operation.amount);
      expect(rebuilt.date, operation.date);
      expect(rebuilt.description, operation.description);
      expect(rebuilt.category, operation.category);
      expect(rebuilt.type, operation.type);
    });

    test('fromJson parses an ISO-8601 date string', () {
      final operation = Operation.fromJson({
        'id': 1,
        'financialAsset': 1,
        'amount': 100.0,
        'date': '2026-05-01T00:00:00.000',
        'description': 'Arriendo',
        'category': 4,
        'type': Operation.expense,
      });

      expect(operation.date, DateTime.parse('2026-05-01T00:00:00.000'));
    });
  });
}
