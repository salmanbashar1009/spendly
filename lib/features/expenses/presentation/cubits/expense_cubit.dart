import 'package:bloc_signals/bloc_signals.dart';
import 'package:flutter/foundation.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:spendly/features/expenses/domain/entities/expense.dart';
import 'package:spendly/features/expenses/domain/entities/expense_category.dart';
import 'package:spendly/features/expenses/presentation/cubits/expense_state.dart';
import 'package:uuid/uuid.dart';

import '../../data/expense_repository.dart';

class ExpenseCubit extends CubitSignal<ExpenseState> {
  ExpenseCubit(this._repository) : super(initialState: ExpenseState.initial());

  final ExpenseRepository _repository;
  final _uuid = const Uuid();

  // ─────────────────────────────────────────────
  // COMMANDS (called by the UI)
  // ─────────────────────────────────────────────

  Future<void> loadExpenses() async {
    try {
      final hasData = await _repository.hasExpenses();
      if (!hasData) {
        // Data is not available — skip full load function and emit empty success state directly
        emit(
          stateValue.copyWith(
            expenses: [],
            status: ExpenseStatus.success,
            clearError: true,
          ),
        );
        return;
      }

      // Data is available — proceed to load expenses
      emit(stateValue.copyWith(status: ExpenseStatus.loading, clearError: true));
      final expenses = await _repository.getExpenses();
      emit(
        stateValue.copyWith(expenses: expenses, status: ExpenseStatus.success),
      );
    } catch (e, stackTrace) {
      debugPrint('ExpenseCubit.loadExpenses error: $e\n$stackTrace');
      emit(
        stateValue.copyWith(
          status: ExpenseStatus.failure,
          error: 'Unable to load expenses: $e',
        ),
      );
    }
  }

  Future<void> addExpense({
    required int amountInCents,
    required ExpenseCategory category,
    required DateTime date,
    required String description,
  }) async {
    try {
      final expense = Expense(
        id: _uuid.v4(),
        amountInCents: amountInCents,
        category: category,
        description: description.trim(),
        date: date,
        createdAt: DateTime.now(),
      );

      await _repository.addExpense(expense);
      final expenses = await _repository.getExpenses();

      emit(
        stateValue.copyWith(
          expenses: expenses,
          status: ExpenseStatus.success,
          clearError: true,
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('ExpenseCubit.addExpense error: $e\n$stackTrace');
      emit(
        stateValue.copyWith(
          status: ExpenseStatus.failure,
          error: 'Unable to save expense: $e',
        ),
      );
    }
  }

  Future<void> updateExpense(Expense expense) async {
    try {
      await _repository.updateExpense(expense);
      final expenses = await _repository.getExpenses();
      emit(
        stateValue.copyWith(
          expenses: expenses,
          status: ExpenseStatus.success,
          clearError: true,
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('ExpenseCubit.updateExpense error: $e\n$stackTrace');
      emit(
        stateValue.copyWith(
          status: ExpenseStatus.failure,
          error: 'Unable to update expense: $e',
        ),
      );
    }
  }

  Future<void> deleteExpense(String id) async {
    try {
      await _repository.deleteExpense(id);
      final expenses = await _repository.getExpenses();
      emit(
        stateValue.copyWith(
          expenses: expenses,
          status: ExpenseStatus.success,
          clearError: true,
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('ExpenseCubit.deleteExpense error: $e\n$stackTrace');
      emit(
        stateValue.copyWith(
          status: ExpenseStatus.failure,
          error: 'Unable to delete expense: $e',
        ),
      );
    }
  }

  void setSearchQuery(String query) {
    emit(stateValue.copyWith(searchQuery: query));
  }

  void setCategoryFilter(ExpenseCategory? category) {
    emit(stateValue.copyWith(selectCategory: category));
  }

  void setDateRange(DateTime? start, DateTime? end) {
    emit(stateValue.copyWith(filterStartDate: start, filterEndDate: end));
  }

  void clearFilters() {
    emit(
      stateValue.copyWith(
        searchQuery: '',
        clearCategory: true,
        clearDates: true,
      ),
    );
  }

  // ─────────────────────────────────────────────
  // DERIVED STATE (Computed Signals)
  // ─────────────────────────────────────────────

  /// Expenses filtered by search, category, and date range.
  /// This is a computed signal — it automatically re-evaluates when
  /// any of its dependencies (state.value) change.

  late final filteredExpenses = computed(() {
    final current = state.value;

    return current.expenses.where((expense) {
      // Search filter
      final matchesSearch =
          current.searchQuery!.isEmpty ||
          expense.description.toLowerCase().contains(
            current.searchQuery!.toLowerCase(),
          ) ||
          expense.category.displayName.toLowerCase().contains(
            current.searchQuery!.toLowerCase(),
          );

      //Category Filter
      final matchesCategory =
          current.selectCategory == null ||
          expense.category == current.selectCategory;

      // Date range filter
      final matchesDate = () {
        if (current.filterStartDate == null && current.filterEndDate == null) {
          return true;
        }
        if (current.filterStartDate != null &&
            expense.date.isBefore(current.filterStartDate!)) {
          return false;
        }
        if (current.filterEndDate != null &&
            expense.date.isAfter(current.filterEndDate!)) {
          return false;
        }
        return true;
      }();

      return matchesSearch && matchesCategory && matchesDate;
    }).toList();
  });

  /// Expenses from the current month.
  late final monthlyExpenses = computed(() {
    final now = DateTime.now();
    return filteredExpenses.value.where((e) {
      return e.date.year == now.year && e.date.month == now.month;
    }).toList();
  });

  /// Total spending this month (in cents).
  late final monthlyTotalCents = computed(() {
    return monthlyExpenses.value.fold<int>(
      0,
      (sum, e) => sum + e.amountInCents,
    );
  });

  /// Total spending across all expenses in cents
  late final grandTotalCents = computed(() {
    return state.value.expenses.fold<int>(0, (sum, e) => sum + e.amountInCents);
  });

  /// Breakdown of spending by category
  late final categoryTotals = computed(() {
    final totals = <ExpenseCategory, int>{};
    for (final expense in state.value.expenses) {
      totals[expense.category] =
          (totals[expense.category] ?? 0) + expense.amountInCents;
    }
    return totals;
  });

  /// Number of transactions
  late final transactionCount = computed(() => state.value.expenses.length);

  /// Top spending category
  late final topCategory = computed(() {
    if (categoryTotals.value.isEmpty) return null;
    return categoryTotals.value.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  });

  // ─────────────────────────────────────────────
  // DEMO DATA
  // ─────────────────────────────────────────────

  Future<void> seedDemoData() async {
    final now = DateTime.now();
    final demoExpenses = [
      Expense(
        id: _uuid.v4(),
        amountInCents: 1250,
        category: ExpenseCategory.food,
        description: 'Lunch at cafe',
        date: now.subtract(const Duration(days: 1)),
        createdAt: now,
      ),
      Expense(
        id: _uuid.v4(),
        amountInCents: 4500,
        category: ExpenseCategory.transport,
        description: 'Monthly transit pass',
        date: now.subtract(const Duration(days: 3)),
        createdAt: now,
      ),
      Expense(
        id: _uuid.v4(),
        amountInCents: 8999,
        category: ExpenseCategory.bills,
        description: 'Electricity bill',
        date: now.subtract(const Duration(days: 5)),
        createdAt: now,
      ),
      Expense(
        id: _uuid.v4(),
        amountInCents: 3200,
        category: ExpenseCategory.shopping,
        description: 'Groceries',
        date: now.subtract(const Duration(days: 2)),
        createdAt: now,
      ),
      Expense(
        id: _uuid.v4(),
        amountInCents: 1500,
        category: ExpenseCategory.entertainment,
        description: 'Movie night',
        date: now.subtract(const Duration(days: 4)),
        createdAt: now,
      ),
    ];

    for (final expense in demoExpenses) {
      await _repository.addExpense(expense);
    }
    await loadExpenses();
  }
}
