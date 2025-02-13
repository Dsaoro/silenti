class CategoryType {
  static int all = 0;
  static int income = 1;
  static int spent = 2;
}

class BudgetCategory {
  final int id;
  final CategoryType type;
  final String name;
  final double amount;

  BudgetCategory({
    required this.id,
    required this.type,
    required this.amount,
    required this.name,
  });

  Map<String, dynamic> toJson() =>
      {'id': id, 'type': type, 'name': name, 'amount': amount};

  factory BudgetCategory.fromJson(Map<String, dynamic> json) => BudgetCategory(
        id: json['id'],
        type: json['type'],
        name: json['name'],
        amount: json['amount'],
      );
}
