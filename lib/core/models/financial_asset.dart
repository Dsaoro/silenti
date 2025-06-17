import 'package:silenti/generated/l10n.dart';

class FinancialAssetFrequency {
  // 'daily', 'weekly', 'semi-monthly', 'monthly', 'anual', 'once'
  static const String daily = "daily";
  static const String weekly = "weekly";
  static const String monthly = "monthly";
  static const String semiMonthly = "semi-monthly";
  static const String anual = "anual";
  static const String once = "once";

  static const List<String> list = [
    once,
    daily,
    weekly,
    semiMonthly,
    monthly,
    anual,
  ];

  static final List<String> listNames = [
    S.current.frecOnce,
    S.current.frecDaily,
    S.current.frecWeekly,
    S.current.frecSemiMonthly,
    S.current.frecMonthly,
    S.current.frecAnual,
  ];

  static Map<String, String> getMap = {
    S.current.frecOnce: once,
    S.current.frecDaily: daily,
    S.current.frecWeekly: weekly,
    S.current.frecMonthly: monthly,
    S.current.frecSemiMonthly: semiMonthly,
    S.current.frecAnual: anual,
  };
}

class FinancialAsset {
  final int id;
  String name;
  double accountBalance;
  int includedOnBalance;
  double interest;
  String frequency;

  FinancialAsset(
    this.id,
    this.name,
    this.accountBalance,
    this.includedOnBalance,
    this.interest,
    this.frequency,
  );

  factory FinancialAsset.fromMap(Map<String, dynamic> map) {
    return FinancialAsset(
      map['id'],
      map['name'],
      map['balance'] ?? 0.0,
      map['included'] ?? 0,
      map['interestRate'] ?? 0,
      map['frequency'] ?? "",
    );
  }
  toMap() {
    return {
      // 'id': id,
      'name': name,
      'balance': accountBalance,
      'included': includedOnBalance,
      'interestRate': interest,
      'frequency': frequency,
    };
  }
}
