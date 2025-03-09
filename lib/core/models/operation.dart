class Operation {
  final int id;
  final int financialAsset;
  final double amount;
  final DateTime date;
  final String description;
  final String category;
  final String type; // "ingreso" o "gasto"

  Operation({
    required this.id,
    required this.financialAsset,
    required this.amount,
    required this.date,
    required this.description,
    required this.category,
    required this.type,
  });

  factory Operation.fromJson(Map<String, dynamic> json) => Operation(
        id: json['id'],
        financialAsset: json['financialAsset'],
        amount: json['amount'],
        date: DateTime.parse(json['date']),
        description: json['description'],
        category: json['category'],
        type: json['type'],
      );
  factory Operation.fromMap(Map<String, dynamic> map) => Operation(
        id: map['id'],
        financialAsset: map['financialAsset'],
        amount: map['amount'],
        date: DateTime.parse(map['date']),
        description: map['description'],
        category: map['category'],
        type: map['type'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'financialAsset': financialAsset,
        'amount': amount,
        'date': date.toIso8601String(),
        'description': description,
        'category': category,
        'type': type,
      };

  Map<String, dynamic> toMap() => toJson();
}
