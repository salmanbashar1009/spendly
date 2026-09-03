import 'package:flutter/material.dart';
import 'package:bloc_signals_flutter/bloc_signals_flutter.dart';
import '../../domain/entities/expense.dart';
import '../cubits/expense_cubit.dart';
import '../widgets/expense_form.dart';

class AddExpenseScreen extends StatelessWidget {
  const AddExpenseScreen({super.key, this.expense});

  final Expense? expense;

  @override
  Widget build(BuildContext context) {
    final isEditing = expense != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Expense' : 'Add Expense'),
      ),
      body: ExpenseForm(
        expense: expense,
        onSave: (amountInCents, category, date, description) async {
          final cubit = context.read<ExpenseCubit>();

          if (isEditing) {
            await cubit.updateExpense(
              expense!.copyWith(
                amountInCents: amountInCents,
                category: category,
                date: date,
                description: description,
              ),
            );
          } else {
            await cubit.addExpense(
              amountInCents: amountInCents,
              category: category,
              date: date,
              description: description,
            );
          }

          if (context.mounted) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}