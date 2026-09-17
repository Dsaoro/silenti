import 'package:flutter_test/flutter_test.dart';
import 'package:silenti/core/models/balance_history.dart';

void main() {
  group('BalanceHistory', () {
    test('toMap does not include id (autoincrement column)', () {
      final entry = BalanceHistory(
        id: 5,
        financialAssetId: 1,
        balance: 1000,
        date: DateTime(2026, 2, 1),
        operationId: 9,
      );

      expect(entry.toMap().containsKey('id'), isFalse);
    });

    test('fromMap/toMap round-trip preserves every field', () {
      final entry = BalanceHistory(
        id: 0,
        financialAssetId: 2,
        balance: 4321.5,
        date: DateTime(2026, 4, 3, 12),
        operationId: 17,
      );

      final map = entry.toMap()..['id'] = 3;
      final rebuilt = BalanceHistory.fromMap(map);

      expect(rebuilt.id, 3);
      expect(rebuilt.financialAssetId, entry.financialAssetId);
      expect(rebuilt.balance, entry.balance);
      expect(rebuilt.date, entry.date);
      expect(rebuilt.operationId, entry.operationId);
    });

    test('operationId is nullable (initial balance has no triggering operation)', () {
      final entry = BalanceHistory.fromMap({
        'id': 1,
        'financialAssetId': 1,
        'balance': 0.0,
        'date': '2026-01-01T00:00:00.000',
        'operationId': null,
      });

      expect(entry.operationId, isNull);
    });

    test('daysSinceEpoch matches the date in milliseconds, for fl_chart', () {
      final date = DateTime(2026, 1, 1);
      final entry = BalanceHistory(
        id: 1,
        financialAssetId: 1,
        balance: 0,
        date: date,
      );

      expect(entry.daysSinceEpoch, date.millisecondsSinceEpoch.toDouble());
    });
  });
}
