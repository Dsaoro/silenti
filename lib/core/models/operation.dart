class Operation {
  // id INTEGER PRIMARY KEY AUTOINCREMENT,
  // financialAsset INTEGER NOT NULL,
  // amount REAL NOT NULL,
  // date TEXT NOT NULL,
  // description TEXT,
  // category INTEGER NOT NULL,
  // type TEXT CHECK(type IN ('income', 'spent')) NOT NULL,
  // FOREIGN KEY (financialAsset) REFERENCES financial_assets(id)
  // FOREIGN KEY (category) REFERENCES budget_categories(id)

  final int id;
  final int financialAsset;
  final double amount;
  final DateTime date;
  final String description;
  final int category;
  final String type; // "ingreso" o "gasto"
  static const String income = "income";
  static const String expense = "spent";

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

  Map<String, dynamic> toMap() => {
        //The 'id': id, field is set for autoincrement and shouldn't be sent to DB
        'financialAsset': financialAsset,
        'amount': amount,
        'date': date.toIso8601String(),
        'description': description,
        'category': category,
        'type': type,
      };

  Map<String, dynamic> toJson() => toMap();
}
