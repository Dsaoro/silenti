class SpendSubCategories {
  // id INTEGER PRIMARY KEY AUTOINCREMENT,
  // category INTEGER NOT NULL,
  // name TEXT NOT NULL,
  // amount REAL NOT NULL,
  // FOREIGN KEY (category) REFERENCES budget_categories(id)
  int id;
  int category;
  String name;
  double amount;

  SpendSubCategories(
      {required this.id,
      required this.category,
      required this.name,
      required this.amount});

  Map<String, dynamic> toMap() => {
        'id': id,
        'category': category,
        'name': name,
        'amount': amount,
      };

  factory SpendSubCategories.fromMap(Map<String, dynamic> map) =>
      SpendSubCategories(
        id: map['id'],
        category: map['category'],
        name: map['name'],
        amount: map['amount'],
      );
}
