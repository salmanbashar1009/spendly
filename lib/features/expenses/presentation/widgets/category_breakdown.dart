import 'package:flutter/material.dart';
import 'package:bloc_signals_flutter/bloc_signals_flutter.dart';
import '../cubits/expense_cubit.dart';
import '../cubits/expense_state.dart';
import '../../domain/entities/expense_category.dart';

class CategoryBreakdown extends StatelessWidget {
  const CategoryBreakdown({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSignalBuilder<ExpenseCubit, ExpenseState>(
      builder: (context, state) {
        final cubit = context.read<ExpenseCubit>();
        final totals = cubit.categoryTotals.value;

        if (totals.isEmpty) return const SizedBox.shrink();

        final maxTotal = totals.values.reduce((a, b) => a > b ? a : b);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Spending by Category',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...totals.entries.map((entry) {
              final percentage = maxTotal == 0 ? 0.0 : entry.value / maxTotal;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry.key.displayName),
                        Text('\$${(entry.value / 100).toStringAsFixed(2)}'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percentage.toDouble(),
                        minHeight: 8,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _categoryColor(entry.key),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Color _categoryColor(ExpenseCategory category) {
    return switch (category) {
      ExpenseCategory.food => Colors.green,
      ExpenseCategory.transport => Colors.blue,
      ExpenseCategory.bills => Colors.red,
      ExpenseCategory.shopping => Colors.orange,
      ExpenseCategory.entertainment => Colors.purple,
      ExpenseCategory.health => Colors.pink,
      ExpenseCategory.education => Colors.indigo,
      ExpenseCategory.other => Colors.grey,
    };
  }
}