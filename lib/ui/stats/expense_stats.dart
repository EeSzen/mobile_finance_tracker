import 'package:fintrack/data/enums/expenses_category.dart';
import 'package:fintrack/data/model/expense.dart';
import 'package:fintrack/data/repo/services/expense_service.dart';
import 'package:fintrack/ui/stats/charts/expense_chart.dart';
import 'package:flutter/material.dart';

class ExpenseStats extends StatelessWidget {
  const ExpenseStats({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Expense>>(
      stream: ExpenseService().getExpensesStream(),
      builder: (context, snap) {
        if (snap.hasError) {
          return Center(
            child: Text('Error: ${snap.error}\n${snap.stackTrace}'),
          );
        }

        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final expenses = snap.data!;

        final Map<ExpenseCategory, double> totals = {};

        for (final e in expenses) {
          totals[e.category] = (totals[e.category] ?? 0) + e.amount;
        }

        // return Text("Test: ${expenses.length} expenses");
        return ExpenseChart(totals: totals);
      },
    );
  }
}
