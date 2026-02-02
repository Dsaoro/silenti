import 'package:silenti/core/models/base_model.dart';
import 'package:silenti/generated/l10n.dart';

enum Frequency {
  daily,
  weekly,
  semiMonthly,
  monthly,
  anual,
  once;

  String get label {
    switch (this) {
      case Frequency.daily:
        return S.current.frecDaily;
      case Frequency.weekly:
        return S.current.frecWeekly;
      case Frequency.semiMonthly:
        return S.current.frecSemiMonthly;
      case Frequency.monthly:
        return S.current.frecMonthly;
      case Frequency.anual:
        return S.current.frecAnnual;
      case Frequency.once:
        return S.current.frecOnce;
    }
  }

  static Frequency fromString(String value) {
    return Frequency.values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => Frequency.once,
    );
  }
}

abstract class FinancialAsset implements BaseModel {
  @override
  final int id;
  final String name;
  final int includedOnBalance; // 1 or 0
  final Frequency frequency;

  FinancialAsset({
    required this.id,
    required this.name,
    required this.includedOnBalance,
    required this.frequency,
  });

  double get currentBalance;

  @override
  Map<String, dynamic> toMap();

  static FinancialAsset fromMap(Map<String, dynamic> map) {
    final type = map['type'] as String? ?? 'BANK';
    if (type == 'INVESTMENT') {
      return InvestmentAsset.fromMap(map);
    } else {
      return BankAccount.fromMap(map);
    }
  }
}

class BankAccount extends FinancialAsset {
  final double balance;
  final double interestRate;

  BankAccount({
    required int id,
    required String name,
    required int includedOnBalance,
    required Frequency frequency,
    required this.balance,
    required this.interestRate,
  }) : super(
          id: id,
          name: name,
          includedOnBalance: includedOnBalance,
          frequency: frequency,
        );

  @override
  double get currentBalance => balance;

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id == 0 ? null : id, // Auto-increment
      'type': 'BANK',
      'name': name,
      'balance': balance,
      'included': includedOnBalance,
      'frequency': frequency.toString().split('.').last,
      'interestRate': interestRate,
    };
  }

  factory BankAccount.fromMap(Map<String, dynamic> map) {
    return BankAccount(
      id: map['id'],
      name: map['name'],
      includedOnBalance: map['included'] ?? 0,
      frequency: Frequency.fromString(map['frequency'] ?? 'once'),
      balance: (map['balance'] ?? 0.0).toDouble(),
      interestRate: (map['interestRate'] ?? 0.0).toDouble(),
    );
  }
}

class InvestmentAsset extends FinancialAsset {
  final double quantity;
  final double currentPrice;
  final String tickerSymbol;

  InvestmentAsset({
    required int id,
    required String name,
    required int includedOnBalance,
    required Frequency frequency,
    required this.quantity,
    required this.currentPrice,
    required this.tickerSymbol,
  }) : super(
          id: id,
          name: name,
          includedOnBalance: includedOnBalance,
          frequency: frequency,
        );

  @override
  double get currentBalance => quantity * currentPrice;

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id == 0 ? null : id,
      'type': 'INVESTMENT',
      'name': name,
      'included': includedOnBalance,
      'frequency': frequency.toString().split('.').last,
      'quantity': quantity, // Stored in specific column or JSON
      'currentPrice': currentPrice, // Stored in balance or separate
      'balance': currentBalance, // Store calculated for easy query
      'tickerSymbol': tickerSymbol,
    };
  }

  factory InvestmentAsset.fromMap(Map<String, dynamic> map) {
    return InvestmentAsset(
      id: map['id'],
      name: map['name'],
      includedOnBalance: map['included'] ?? 0,
      frequency: Frequency.fromString(map['frequency'] ?? 'once'),
      quantity: (map['quantity'] ?? 0.0).toDouble(),
      currentPrice: (map['currentPrice'] ?? 0.0).toDouble(),
      tickerSymbol: map['tickerSymbol'] ?? '',
    );
  }
}
