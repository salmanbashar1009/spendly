import 'package:equatable/equatable.dart';

import '../../domain/entities/expense.dart';
import '../../domain/entities/expense_category.dart';

enum ExpenseStatus { initial, loading, success, failure }

class ExpenseState extends Equatable {
  const ExpenseState({
    required this.expenses,
    required this.status,
    this.error,
    required this.searchQuery,
    this.selectCategory,
    this.filterStartDate,
    this.filterEndDate,
  });

  final List<Expense> expenses;
  final ExpenseStatus status;
  final String? error;
  final String? searchQuery;
  final ExpenseCategory? selectCategory;
  final DateTime? filterStartDate;
  final DateTime? filterEndDate;

  factory ExpenseState.initial() {
    return const ExpenseState(
      expenses: [],
      status: ExpenseStatus.initial,
      error: null,
      searchQuery: '',
      selectCategory: null,
      filterStartDate: null,
      filterEndDate: null,
    );
  }

  ExpenseState copyWith({
    List<Expense>? expenses,
    ExpenseStatus? status,
    String? error,
    bool clearError = false,
    String? searchQuery,
    ExpenseCategory? selectCategory,
    DateTime? filterStartDate,
    DateTime? filterEndDate,
    bool clearDates = false,
    bool clearCategory = false,
  }) {
    return ExpenseState(
      expenses: expenses ?? this.expenses,
      status: status ?? this.status,
      searchQuery: searchQuery ?? this.searchQuery,
      selectCategory: clearCategory
          ? null
          : (selectCategory ?? this.selectCategory),
      filterStartDate: clearDates
          ? null
          : (filterStartDate ?? this.filterStartDate),
      filterEndDate: clearDates ? null : (filterEndDate ?? this.filterEndDate),
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [
    expenses,
    status,
    error,
    searchQuery,
    selectCategory,
    filterStartDate,
    filterEndDate,
  ];
}
