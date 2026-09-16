// lib/features/expenses/presentation/screens/expense_list_screen.dart
import 'package:flutter/material.dart';
import 'package:bloc_signals_flutter/bloc_signals_flutter.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/expense_category.dart';
import '../cubits/expense_cubit.dart';
import '../cubits/expense_state.dart';
import '../widgets/expense_list_item.dart';
import 'add_expense_screen.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Expenses')),
      body: Column(
        children: [
          _SearchBar(),
          _FilterChips(),
          _DateFilterBar(),
          Expanded(
            child: BlocSignalBuilder<ExpenseCubit, ExpenseState>(
              builder: (context, state) {
                final cubit = context.read<ExpenseCubit>();
                final filtered = cubit.filteredExpenses.value;

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text('No expenses match your filters.'),
                  );
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final expense = filtered[index];
                    return Dismissible(
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
                        onTap: () => _editExpense(context, expense),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addExpense(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _addExpense(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
    );
  }

  Future<void> _editExpense(BuildContext context, Expense expense) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddExpenseScreen(expense: expense),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: const InputDecoration(
          hintText: 'Search expenses...',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(),
        ),
        onChanged: (query) {
          context.read<ExpenseCubit>().setSearchQuery(query);
        },
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocSignalBuilder<ExpenseCubit, ExpenseState>(
      builder: (context, state) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              ActionChip(
                avatar: const Icon(Icons.clear),
                label: const Text('Clear All'),
                onPressed: () => context.read<ExpenseCubit>().clearFilters(),
              ),
              const SizedBox(width: 8),
              ...ExpenseCategory.values.map((category) {
                final isSelected = state.selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category.displayName),
                    selected: isSelected,
                    onSelected: (_) {
                      context.read<ExpenseCubit>().setCategoryFilter(
                        isSelected ? null : category,
                      );
                    },
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class _DateFilterBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocSignalBuilder<ExpenseCubit, ExpenseState>(
      builder: (context, state) {
        final cubit = context.read<ExpenseCubit>();
        final hasDateFilter = state.filterStartDate != null || state.filterEndDate != null;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              TextButton.icon(
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  hasDateFilter
                      ? '${_fmt(state.filterStartDate)} - ${_fmt(state.filterEndDate)}'
                      : 'Filter by Date',
                ),
                onPressed: () => _pickDateRange(context),
              ),
              if (hasDateFilter)
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => cubit.setDateRange(null, null),
                ),
            ],
          ),
        );
      },
    );
  }

  String _fmt(DateTime? dt) => dt == null ? '...' : '${dt.month}/${dt.day}';

  Future<void> _pickDateRange(BuildContext context) async {
    final cubit = context.read<ExpenseCubit>();
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
    );
    if (range != null) {
      cubit.setDateRange(range.start, range.end);
    }
  }
}
