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
      map['balance'] ?? 0.0,
      map['included'] ?? 0,
      map['interestRate'] ?? 0,
      map['frequency'] ?? "",
    );
  }
}
