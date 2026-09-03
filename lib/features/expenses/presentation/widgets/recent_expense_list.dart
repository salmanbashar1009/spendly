import 'package:flutter/material.dart';
import 'package:bloc_signals_flutter/bloc_signals_flutter.dart';
import '../cubits/expense_cubit.dart';
import '../cubits/expense_state.dart';
import 'expense_list_item.dart';

class RecentExpensesList extends StatelessWidget {
  const RecentExpensesList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSignalBuilder<ExpenseCubit, ExpenseState>(
      builder: (context, state) {
        final recent = state.expenses
          ..sort((a, b) => b.date.compareTo(a.date));

        final displayList = recent.take(5).toList();

        if (displayList.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Expenses',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to full list
                  },
                  child: const Text('See All'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...displayList.map((expense) => ExpenseListItem(expense: expense)),
          ],
        );
      },
    );
  }
}