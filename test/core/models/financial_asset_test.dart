import 'package:flutter_test/flutter_test.dart';
import 'package:silenti/core/models/financial_asset.dart';

void main() {
  group('BankAccount', () {
    test('currentBalance returns the stored balance', () {
      final account = BankAccount(
        id: 1,
        name: 'Efectivo',
        includedOnBalance: 1,
        frequency: Frequency.once,
        balance: 5000,
        interestRate: 0,
      );

      expect(account.currentBalance, 5000);
    });

    test('toMap/fromMap round-trip preserves every field', () {
      final account = BankAccount(
        id: 3,
        name: 'Cuenta de ahorros',
        includedOnBalance: 1,
        frequency: Frequency.monthly,
        balance: 125000.5,
        interestRate: 0.02,
      );

      final rebuilt = BankAccount.fromMap(account.toMap());

      expect(rebuilt.id, account.id);
      expect(rebuilt.name, account.name);
      expect(rebuilt.includedOnBalance, account.includedOnBalance);
      expect(rebuilt.frequency, Frequency.monthly);
      expect(rebuilt.balance, account.balance);
      expect(rebuilt.interestRate, account.interestRate);
    });

    test('toMap maps id 0 (not yet persisted) to null for autoincrement', () {
      final account = BankAccount(
        id: 0,
        name: 'Nueva cuenta',
        includedOnBalance: 1,
        frequency: Frequency.once,
        balance: 0,
        interestRate: 0,
      );

      expect(account.toMap()['id'], isNull);
    });
  });

  group('InvestmentAsset', () {
    test('currentBalance is quantity times currentPrice', () {
      final asset = InvestmentAsset(
        id: 2,
        name: 'ETF',
        includedOnBalance: 1,
        frequency: Frequency.once,
        quantity: 10,
        currentPrice: 25.5,
        tickerSymbol: 'VOO',
      );

      expect(asset.currentBalance, 255.0);
    });

    test('toMap persists the computed balance alongside quantity/price', () {
      final asset = InvestmentAsset(
        id: 2,
        name: 'ETF',
        includedOnBalance: 1,
        frequency: Frequency.once,
        quantity: 4,
        currentPrice: 100,
        tickerSymbol: 'VOO',
      );

      final map = asset.toMap();

      expect(map['type'], 'INVESTMENT');
      expect(map['balance'], 400.0);
      expect(map['quantity'], 4);
      expect(map['currentPrice'], 100);
      expect(map['tickerSymbol'], 'VOO');
    });

    test('fromMap round-trip preserves every field', () {
      final asset = InvestmentAsset(
        id: 7,
        name: 'Acciones',
        includedOnBalance: 0,
        frequency: Frequency.anual,
        quantity: 3.5,
        currentPrice: 42.1,
        tickerSymbol: 'AAPL',
      );

      final rebuilt = InvestmentAsset.fromMap(asset.toMap());

      expect(rebuilt.id, asset.id);
      expect(rebuilt.quantity, asset.quantity);
      expect(rebuilt.currentPrice, asset.currentPrice);
      expect(rebuilt.tickerSymbol, asset.tickerSymbol);
      expect(rebuilt.currentBalance, asset.currentBalance);
    });
  });

  group('FinancialAsset.fromMap dispatch', () {
    test('type INVESTMENT builds an InvestmentAsset', () {
      final asset = FinancialAsset.fromMap({
        'id': 1,
        'type': 'INVESTMENT',
        'name': 'ETF',
        'included': 1,
        'frequency': 'once',
        'quantity': 2.0,
        'currentPrice': 50.0,
        'tickerSymbol': 'VOO',
      });

      expect(asset, isA<InvestmentAsset>());
      expect(asset.currentBalance, 100.0);
    });

    test('type BANK builds a BankAccount', () {
      final asset = FinancialAsset.fromMap({
        'id': 1,
        'type': 'BANK',
        'name': 'Efectivo',
        'balance': 1000.0,
        'included': 1,
        'frequency': 'once',
        'interestRate': 0.0,
      });

      expect(asset, isA<BankAccount>());
    });

    test('missing type defaults to BankAccount', () {
      final asset = FinancialAsset.fromMap({
        'id': 1,
        'name': 'Efectivo',
        'balance': 500.0,
        'included': 1,
        'frequency': 'once',
        'interestRate': 0.0,
      });

      expect(asset, isA<BankAccount>());
    });
  });

  group('Frequency.fromString', () {
    test('parses every known value', () {
      expect(Frequency.fromString('daily'), Frequency.daily);
      expect(Frequency.fromString('weekly'), Frequency.weekly);
      expect(Frequency.fromString('semiMonthly'), Frequency.semiMonthly);
      expect(Frequency.fromString('monthly'), Frequency.monthly);
      expect(Frequency.fromString('anual'), Frequency.anual);
      expect(Frequency.fromString('once'), Frequency.once);
    });

    test('falls back to once for an unknown value', () {
      expect(Frequency.fromString('not-a-real-frequency'), Frequency.once);
    });
  });
}
