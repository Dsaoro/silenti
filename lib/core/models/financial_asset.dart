class FinancialAsset {
  final int id;
  String name;
  double accountBalance;
  int includedOnBalance;
  double interest;
  String frequency;
  FinancialAsset(this.id, this.name, this.accountBalance,
      this.includedOnBalance, this.interest, this.frequency);

  factory FinancialAsset.fromMap(Map<String, dynamic> map) {
    return FinancialAsset(
      map['id'],
      map['name'],
      map['account_balance'] ?? 0.0,
      map['included_on_balance'] ?? 0,
      map['interest_rate'] ?? 0,
      map['frequency'] ?? "",
    );
  }
}
