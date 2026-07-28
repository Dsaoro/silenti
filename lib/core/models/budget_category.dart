import 'package:silenti/core/models/base_model.dart';

class CategoryType {
  // static String all = 0;
  static const String income = "income";
  static const String spent = "spent";
}

class BudgetCategory implements BaseModel {
  @override
  final int id;
  final int? parentId;
  final String type;
  final String name;
  final double amount;
  final String frequency;
  final DateTime firstTime;
  final List<BudgetCategory> subcategories;

  BudgetCategory({
    required this.id,
    this.parentId,
    required this.type,
    required this.name,
    required this.amount,
    required this.frequency,
    required this.firstTime,
    this.subcategories = const [],
  });

  // Derived property for recursive total
  double get totalAmount =>
      amount + subcategories.fold(0.0, (sum, item) => sum + item.totalAmount);

  @override
  Map<String, dynamic> toMap() => {
        'id': id == 0 ? null : id,
        'parentId': parentId,
        'type': type,
        'name': name,
        'amount': amount,
        'frequency': frequency,
        'firstTime': firstTime.toIso8601String(),
      };

  factory BudgetCategory.fromMap(Map<String, dynamic> map) => BudgetCategory(
        id: map['id'],
        parentId: map['parentId'],
        type: map['type'],
        name: map['name'],
        amount: (map['amount'] ?? 0.0).toDouble(),
        frequency: map['frequency'],
        firstTime: DateTime.parse(map['firstTime']),
        // Subcategories are usually loaded separately or via join,
        // for fromMap basic usage we initialize empty.
        subcategories: [],
      );

  // Helper to reconstruct tree if we have the list
  BudgetCategory copyWith({
    int? id,
    int? parentId,
    String? type,
    String? name,
    double? amount,
    String? frequency,
    DateTime? firstTime,
    List<BudgetCategory>? subcategories,
  }) {
    return BudgetCategory(
      id: id ?? this.id,
      parentId: parentId ?? this.parentId,
      type: type ?? this.type,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      frequency: frequency ?? this.frequency,
      firstTime: firstTime ?? this.firstTime,
      subcategories: subcategories ?? this.subcategories,
    );
  }
}
