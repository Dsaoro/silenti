class Income {
  final int id;
  final String name;
  final double amount;

  Income({required this.id, required this.amount, required this.name});

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'amount': amount};

  factory Income.fromJson(Map<String, dynamic> json) => Income(
        id: json['id'],
        name: json['name'],
        amount: json['amount'],
      );
}
