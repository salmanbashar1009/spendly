import 'package:flutter/material.dart';
import 'package:bloc_signals_flutter/bloc_signals_flutter.dart';
import '../cubits/expense_cubit.dart';
import '../cubits/expense_state.dart';
import '../screens/add_expense_screen.dart';
import '../screens/expense_list_screen.dart';
import 'expense_list_item.dart';

class RecentExpensesList extends StatelessWidget {
  const RecentExpensesList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSignalBuilder<ExpenseCubit, ExpenseState>(
      builder: (context, state) {
        final recent = [...state.expenses]
          ..sort((a, b) => b.date.compareTo(a.date));

        final displayList = recent.take(5).toList();

        if (displayList.isEmpty) {
          return Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 48,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No expenses yet',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap "+ Add Expense" to track your spending',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ExpenseListScreen(),
                      ),
                    );
                  },
                  child: const Text('See All'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...displayList.map((expense) => Dismissible(
                  key: Key(expense.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    return await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Delete Expense'),
                        content: const Text(
                          'Are you sure you want to delete this expense?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                  },
                  onDismissed: (_) {
                    context.read<ExpenseCubit>().deleteExpense(expense.id);
                  },
                  child: ExpenseListItem(
                    expense: expense,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddExpenseScreen(expense: expense),
                        ),
                      );
                    },
                  ),
                )),
          ],
        );
      },
    );
  }
}
