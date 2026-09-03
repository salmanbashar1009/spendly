import 'package:bloc_signals_flutter/bloc_signals_flutter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spendly/features/expenses/presentation/cubits/expense_cubit.dart';
import 'package:spendly/features/expenses/presentation/cubits/expense_state.dart';

class DashboardSummary extends StatelessWidget {
  const DashboardSummary({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSignalBuilder<ExpenseCubit,ExpenseState>(
        builder: (context,state){
          final cubit = context.read<ExpenseCubit>();

          /// Read computed signals. They are always up-to-date.
          final monthlyTotal = cubit.monthlyTotalCents.value;
          final transactionCount = cubit.transactionCount.value;
          final topCategory = cubit.topCategory.value;

          final currencyFormat = NumberFormat.currency(symbol: "\$");

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('This Month', style:  Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold
              ),),
              const SizedBox(height: 12,),
              Row(
                children: [
                  Expanded(child: _SummaryCard(
                    title: 'Total Spent',
                    value: currencyFormat.format(monthlyTotal/100),
                    icon: Icons.account_balance_wallet,
                    color: Colors.teal,
                  )),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SummaryCard(
                      title: 'Transactions',
                      value: '$transactionCount',
                      icon: Icons.receipt_long,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12,),
              if(topCategory != null)
                _SummaryCard(title: 'Top Category', value: topCategory.displayName, icon: Icons.category, color: Colors.purple)
            ],
          );
        }
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsetsGeometry.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color,),
            const SizedBox(height: 8,),
            Text(value,style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
