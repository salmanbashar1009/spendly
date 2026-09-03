// lib/features/expenses/domain/entities/expense.dart
import 'package:equatable/equatable.dart';
import 'expense_category.dart';

class Expense extends Equatable {
  const Expense({
    required this.id,
    required this.amountInCents,
    required this.category,
    required this.description,
    required this.date,
    required this.createdAt,
  });

  final String id;
  final int amountInCents;
  final ExpenseCategory category;
  final String description;
  final DateTime date;
  final DateTime createdAt;

  /// Converts cents to dollars for display.
  /// Example: 1250 cents → $12.50
  double get amountInDollars => amountInCents / 100.0;

  Expense copyWith({
    String? id,
    int? amountInCents,
    ExpenseCategory? category,
    String? description,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return Expense(
      id: id ?? this.id,
      amountInCents: amountInCents ?? this.amountInCents,
      category: category ?? this.category,
      description: description ?? this.description,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amountInCents': amountInCents,
      'category': category.name,
      'description': description,
      'date': date.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as String,
      amountInCents: map['amountInCents'] as int,
      category: ExpenseCategory.fromString(map['category'] as String),
      description: map['description'] as String,
      date: DateTime.parse(map['date'] as String),
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  @override
  List<Object?> get props => [
    id,
    amountInCents,
    category,
    description,
    date,
    createdAt,
  ];
}
