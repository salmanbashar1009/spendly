import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/expense_category.dart';

class ExpenseListItem extends StatelessWidget {
  const ExpenseListItem({
    super.key,
    required this.expense,
    this.onTap,
  });

  final Expense expense;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(_categoryIcon(expense.category)),
        ),
        title: Text(expense.description),
        subtitle: Text(
          '${expense.category.displayName} • ${DateFormat.yMMMd().format(expense.date)}',
        ),
        trailing: Text(
          currencyFormat.format(expense.amountInDollars),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  IconData _categoryIcon(ExpenseCategory category) {
    return switch (category) {
      ExpenseCategory.food => Icons.restaurant,
      ExpenseCategory.transport => Icons.directions_car,
      ExpenseCategory.bills => Icons.receipt,
      ExpenseCategory.shopping => Icons.shopping_bag,
      ExpenseCategory.entertainment => Icons.movie,
      ExpenseCategory.health => Icons.health_and_safety,
      ExpenseCategory.education => Icons.school,
      ExpenseCategory.other => Icons.more_horiz,
    };
  }
}