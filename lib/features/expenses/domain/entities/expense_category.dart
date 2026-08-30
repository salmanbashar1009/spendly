// lib/features/expenses/domain/entities/expense_category.dart
enum ExpenseCategory {
  food,
  transport,
  bills,
  shopping,
  entertainment,
  health,
  education,
  other;

  String get displayName {
    return name[0].toUpperCase() + name.substring(1);
  }

  static ExpenseCategory fromString(String value) {
    return ExpenseCategory.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => ExpenseCategory.other,
    );
  }
}
