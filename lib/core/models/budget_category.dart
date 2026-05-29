class CategoryType {
  // static String all = 0;
  static String income = "income";
  static String spent = "spent";
}

class BudgetCategory {
//  id INTEGER PRIMARY KEY AUTOINCREMENT,
//  type TEXT CHECK(type IN ('income', 'spent') NOT NULL),
//  name TEXT NOT NULL,
//  amount REAL NOT NULL,
//  frequency TEXT CHECK(frequency IN ('daily', 'weekly', 'semi-monthly', 'monthly', 'anual', 'once')) NOT NULL,
//  firstTime

  int id;
  String type;
  String name;
  double amount;
  String frequency;
  DateTime firstTime = DateTime.now();

  final String now = DateTime.now().toString();
  BudgetCategory({
    required this.id,
    required this.type,
    required this.amount,
    required this.name,
    required this.frequency,
    required this.firstTime,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'name': name,
        'amount': amount,
      };

  Map<String, dynamic> toMap() => {
        //The 'id': id, field is set for autoincrement and shouldn't be sent to DB
        'type': type,
        'name': name,
        'amount': amount,
        'frequency': frequency,
        'firstTime': firstTime.toIso8601String(),
      };

  factory BudgetCategory.fromJson(Map<String, dynamic> json) => BudgetCategory(
        id: json['id'],
        type: json['type'],
        name: json['name'],
        amount: json['amount'],
        frequency: json['frequency'],
        firstTime: json['firstTime'],
      );
  factory BudgetCategory.fromMap(Map<String, dynamic> map) => BudgetCategory(
        id: map['id'],
        type: map['type'],
        name: map['name'],
        amount: map['amount'],
        frequency: map['frequency'],
        firstTime: map['firstTime'],
      );
}
