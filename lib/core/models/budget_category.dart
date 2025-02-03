class BudgetCategory {
  final int id;
  final String name;
  final double amount;

  BudgetCategory({required this.id, required this.amount, required this.name});

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'amount': amount};

  factory BudgetCategory.fromJson(Map<String, dynamic> json) => BudgetCategory(
        id: json['id'],
        name: json['name'],
        amount: json['amount'],
      );
}
