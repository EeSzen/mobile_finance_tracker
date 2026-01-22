import 'package:fintrack/auth/auth.dart';
import 'package:fintrack/data/enums/expenses_category.dart';
import 'package:fintrack/data/enums/income_category.dart';
import 'package:fintrack/data/model/expense.dart';
import 'package:fintrack/data/model/revenue.dart';
import 'package:fintrack/data/repo/services/expense_service.dart';
import 'package:fintrack/data/repo/services/revenue_service.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final _expenseService = ExpenseService();
  final _revenueService = RevenueService();

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Expense>>(
      stream: _expenseService.getExpensesStream(),
      builder: (context, expenseSnap) {
        if (!expenseSnap.hasData) return const Center(child: CircularProgressIndicator());

        final expenses = expenseSnap.data!;
        final totalExpense = expenses.fold(0.0, (sum, e) => sum + e.amount);

        return StreamBuilder<List<Revenue>>(
          stream: _revenueService.getRevenuesStream(),
          builder: (context, revenueSnap) {
            if (!revenueSnap.hasData) return const Center(child: CircularProgressIndicator());

            final revenues = revenueSnap.data!;
            final totalIncome = revenues.fold(0.0, (sum, r) => sum + r.amount);
            final balance = totalIncome - totalExpense;

            return _HomeLayout(
              expenses: expenses,
              revenues: revenues,
              balance: balance,
              totalExpense: totalExpense,
              totalIncome: totalIncome,
            );
          },
        );
      },
    );
  }
}

// UI for home
class _HomeLayout extends StatelessWidget {
  final List<Expense> expenses;
  final List<Revenue> revenues;
  final double balance;
  final double totalExpense;
  final double totalIncome;

  const _HomeLayout({
    required this.expenses,
    required this.revenues,
    required this.balance,
    required this.totalExpense,
    required this.totalIncome,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("FinTrack"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: signOut,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _BalanceCard(balance: balance),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    title: "Income",
                    amount: totalIncome,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _SummaryCard(
                    title: "Expense",
                    amount: totalExpense,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Recent Transactions",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _TransactionList(
                expenses: expenses,
                revenues: revenues,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// Icons
IconData categoryIcon(String category, {bool isIncome = false}) {
  if (isIncome) {
    switch (category.toLowerCase()) {
      case 'salary':
        return Icons.work;
      case 'bonus':
        return Icons.card_giftcard;
      case 'investment':
        return Icons.trending_up;
      default:
        return Icons.attach_money;
    }
  } else {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant;
      case 'transport':
        return Icons.directions_bus;
      case 'shopping':
        return Icons.shopping_bag;
      case 'bills':
        return Icons.receipt_long;
      default:
        return Icons.money_off;
    }
  }
}




class _BalanceCard extends StatelessWidget {
  final double balance;

  const _BalanceCard({required this.balance});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Total Balance",
              style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          Text(
            "RM${balance.toStringAsFixed(2)}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}


class _SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: color)),
          const SizedBox(height: 8),
          Text(
            "RM${amount.toStringAsFixed(2)}",
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}


//  Helper function for First letter uppercase
String capitalize(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1);
}



class _TransactionList extends StatelessWidget {
  final List<Expense> expenses;
  final List<Revenue> revenues;

  const _TransactionList({required this.expenses, required this.revenues});

  @override
  Widget build(BuildContext context) {
    // Combine both lists, most recent first
    final transactions = [
      ...expenses.map((e) => {'type': 'expense', 'data': e}),
      ...revenues.map((r) => {'type': 'revenue', 'data': r}),
    ]..sort((a, b) {
        final aTime = (a['data'] as dynamic).timestamp as DateTime;
        final bTime = (b['data'] as dynamic).timestamp as DateTime;
        return bTime.compareTo(aTime);
      });

    return ListView.separated(
      itemCount: transactions.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final tx = transactions[index];
        if (tx['type'] == 'expense') {
          final e = tx['data'] as Expense;
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.red.shade100,
                child: Icon(e.category.icon, color: Colors.red),
              ),
              title: Text(
                e.category.label,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                e.note,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Text(
                "-RM${e.amount.toStringAsFixed(2)}",
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        } else {
          final r = tx['data'] as Revenue;
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.green.shade100,
                child: Icon(r.category.icon, color: Colors.green),
              ),
              title: Text(
                r.category.label,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                r.source,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Text(
                "+RM${r.amount.toStringAsFixed(2)}",
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );

        }
      },
    );
  }
}

