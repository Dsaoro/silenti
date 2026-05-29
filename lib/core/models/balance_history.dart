class BalanceHistory {
  final int id;
  final int financialAssetId;
  final double balance;
  final DateTime date;
  final int? operationId; // Referencia a la operación que causó este cambio

  BalanceHistory({
    required this.id,
    required this.financialAssetId,
    required this.balance,
    required this.date,
    this.operationId,
  });

  factory BalanceHistory.fromMap(Map<String, dynamic> map) {
    return BalanceHistory(
      id: map['id'],
      financialAssetId: map['financialAssetId'],
      balance: map['balance']?.toDouble() ?? 0.0,
      date: DateTime.parse(map['date']),
      operationId: map['operationId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'financialAssetId': financialAssetId,
      'balance': balance,
      'date': date.toIso8601String(),
      'operationId': operationId,
    };
  }

  // Para fl_chart
  double get daysSinceEpoch => date.millisecondsSinceEpoch.toDouble();
}
