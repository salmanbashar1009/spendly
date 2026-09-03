// lib/app.dart
import 'package:flutter/material.dart';
import 'package:bloc_signals_flutter/bloc_signals_flutter.dart';
import 'package:spendly/features/expenses/presentation/screens/dashboard_screen.dart';
import 'features/expenses/data/expense_repository.dart';
import 'features/expenses/presentation/cubits/expense_cubit.dart';

class SpendlyApp extends StatelessWidget {
  const SpendlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spendly',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      home: BlocSignalProvider(
        create: (context) =>
            ExpenseCubit(InMemoryExpenseRepository())..seedDemoData(),
        child: const DashboardScreen(),
      ),
    );
  }
}
