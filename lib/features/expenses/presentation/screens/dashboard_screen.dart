import 'package:bloc_signals_flutter/bloc_signals_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:spendly/features/expenses/presentation/cubits/expense_cubit.dart';
import 'package:spendly/features/expenses/presentation/cubits/expense_state.dart';

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
              // Navigator.push(context, MaterialPageRoute(builder: (_)=> const ExpenseListScreen()))
            },
            icon: const Icon(Icons.list),
          ),
        ],
      ),
      body: BlocSignalBuilder<ExpenseCubit, ExpenseState>(
        builder: (context, state) {
          if (state.status == ExpenseStatus.loading && state.expenses.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == ExpenseStatus.failure && state.expenses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ExpenseCubit>().loadExpenses();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return const SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Dashboard summary"),
                Text("category"),
                Text("Recent Expense"),
                // DashboardSummary(),
                // SizedBox(height: 24),
                // CategoryBreakdown(),
                // SizedBox(height: 24),
                // RecentExpensesList(),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
    );
  }
}
