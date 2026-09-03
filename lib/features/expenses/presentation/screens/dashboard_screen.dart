import 'package:bloc_signals_flutter/bloc_signals_flutter.dart';
import 'package:flutter/material.dart';
import 'package:spendly/features/expenses/presentation/cubits/expense_cubit.dart';
import 'package:spendly/features/expenses/presentation/cubits/expense_state.dart';

import '../widgets/category_breakdown.dart';
import '../widgets/dashboard_summary.dart';
import '../widgets/recent_expense_list.dart';
import 'add_expense_screen.dart';
import 'expense_list_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spendly'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ExpenseListScreen()),
              );
            },
            icon: const Icon(Icons.list),
            tooltip: 'All Expenses',
          ),
        ],
      ),
      body: BlocSignalListener<ExpenseCubit, ExpenseState>(
        listener: (context, state) {

         if(state.expenses.isNotEmpty){
           if (state.status == ExpenseStatus.failure && state.error != null) {
             ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(
                 content: Text(state.error!),
                 backgroundColor: Colors.red,
                 action: SnackBarAction(
                   label: 'Dismiss',
                   textColor: Colors.white,
                   onPressed: () {},
                 ),
               ),
             );
           }
         }
        },
        child: BlocSignalBuilder<ExpenseCubit, ExpenseState>(
          builder: (context, state) {
            if (state.status == ExpenseStatus.loading && state.expenses.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.expenses.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 32.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.waving_hand_rounded,
                          size: 56,
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Hello!',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No expense data is available yet.',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                          color: Colors.grey[700],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state.status == ExpenseStatus.failure) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 60,
                        color: Colors.redAccent,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load expenses',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.error ?? 'An unexpected error occurred.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          context.read<ExpenseCubit>().loadExpenses();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }
            return const SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DashboardSummary(),
                  SizedBox(height: 24),
                  CategoryBreakdown(),
                  SizedBox(height: 24),
                  RecentExpensesList(),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
    );
  }
}
