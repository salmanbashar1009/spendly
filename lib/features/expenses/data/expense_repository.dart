import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:spendly/features/expenses/domain/entities/expense.dart';

abstract class ExpenseRepository {
  Future<bool> hasExpenses();
  Future<List<Expense>> getExpenses();
  Future<void> addExpense(Expense expense);
  Future<void> updateExpense(Expense expense);
  Future<void> deleteExpense(String expenseId);
}

class SqfliteExpenseRepository implements ExpenseRepository {
  static Database? _db;
  final InMemoryExpenseRepository _fallback = InMemoryExpenseRepository();
  bool _useFallback = kIsWeb;

  Future<Database?> get _database async {
    if (_useFallback) return null;
    if (_db != null) return _db;
    try {
      _db = await _initDb();
      return _db;
    } catch (e) {
      debugPrint('Sqflite initialization failed, using in-memory fallback: $e');
      _useFallback = true;
      return null;
    }
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'spendly.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await _createTable(db);
      },
      onOpen: (db) async {
        await _createTable(db);
      },
    );
  }

  static Future<void> _createTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS expenses (
        id TEXT PRIMARY KEY,
        amountInCents INTEGER NOT NULL,
        category TEXT NOT NULL,
        description TEXT NOT NULL,
        date TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  @override
  Future<bool> hasExpenses() async {
    final db = await _database;
    if (db == null) return _fallback.hasExpenses();
    try {
      final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM expenses'),
      );
      return (count ?? 0) > 0;
    } catch (e) {
      debugPrint('SqfliteExpenseRepository.hasExpenses error: $e');
      return _fallback.hasExpenses();
    }
  }

  @override
  Future<List<Expense>> getExpenses() async {
    final db = await _database;
    if (db == null) return _fallback.getExpenses();
    try {
      final maps = await db.query('expenses', orderBy: 'date DESC');
      return maps.map((map) => Expense.fromMap(map)).toList();
    } catch (e) {
      debugPrint('SqfliteExpenseRepository.getExpenses error: $e');
      return _fallback.getExpenses();
    }
  }

  @override
  Future<void> addExpense(Expense expense) async {
    final db = await _database;
    if (db == null) return _fallback.addExpense(expense);
    try {
      await db.insert(
        'expenses',
        expense.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      debugPrint('SqfliteExpenseRepository.addExpense error: $e');
      await _fallback.addExpense(expense);
    }
  }

  @override
  Future<void> updateExpense(Expense expense) async {
    final db = await _database;
    if (db == null) return _fallback.updateExpense(expense);
    try {
      await db.update(
        'expenses',
        expense.toMap(),
        where: 'id = ?',
        whereArgs: [expense.id],
      );
    } catch (e) {
      debugPrint('SqfliteExpenseRepository.updateExpense error: $e');
      await _fallback.updateExpense(expense);
    }
  }

  @override
  Future<void> deleteExpense(String expenseId) async {
    final db = await _database;
    if (db == null) return _fallback.deleteExpense(expenseId);
    try {
      await db.delete(
        'expenses',
        where: 'id = ?',
        whereArgs: [expenseId],
      );
    } catch (e) {
      debugPrint('SqfliteExpenseRepository.deleteExpense error: $e');
      await _fallback.deleteExpense(expenseId);
    }
  }
}

class InMemoryExpenseRepository implements ExpenseRepository {
  final List<Expense> _expenses = [];

  @override
  Future<bool> hasExpenses() async {
    return _expenses.isNotEmpty;
  }

  @override
  Future<List<Expense>> getExpenses() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return List.unmodifiable(_expenses);
  }

  @override
  Future<void> addExpense(Expense expense) async {
    await Future.delayed(const Duration(milliseconds: 50));
    _expenses.add(expense);
  }

  @override
  Future<void> updateExpense(Expense expense) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final index = _expenses.indexWhere((e) => e.id == expense.id);
    if (index != -1) {
      _expenses[index] = expense;
    }
  }

  @override
  Future<void> deleteExpense(String expenseId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    _expenses.removeWhere((e) => e.id == expenseId);
  }
}
