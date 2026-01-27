import 'package:fintrack/data/enums/expenses_category.dart';
import 'package:fintrack/data/enums/income_category.dart';
import 'package:fintrack/data/model/expense.dart';
import 'package:fintrack/data/model/revenue.dart';
import 'package:fintrack/data/repo/services/expense_service.dart';
import 'package:fintrack/data/repo/services/revenue_service.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class AnnualSummaryScreen extends StatefulWidget {
  const AnnualSummaryScreen({super.key});

  @override
  State<AnnualSummaryScreen> createState() => _AnnualSummaryScreenState();
}

class _AnnualSummaryScreenState extends State<AnnualSummaryScreen> {
  int selectedYear = DateTime.now().year;  // Default to current year

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Annual Summary'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareReport(context),
            tooltip: 'Share Report',
          ),
        ],
      ),
      body: Column(
        children: [
          // Year Picker Section
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select Year:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                InkWell(
                  onTap: _selectYear,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Text(
                          selectedYear.toString(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.calendar_today, size: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Summary Content
          Expanded(child: _buildSummaryContent()),
        ],
      ),
    );
  }

  Widget _buildSummaryContent() {
    return StreamBuilder<Map<String, dynamic>>(
      stream: Rx.zip2(
        ExpenseService().getExpensesStream(),
        RevenueService().getRevenuesStream(),
        (expenses, revenues) => {
          "expenses": expenses,
          "revenues": revenues,
        },
      ),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final allExpenses = snap.data!["expenses"] as List<Expense>;
        final allRevenues = snap.data!["revenues"] as List<Revenue>;

        // Filter by selected year
        final yearExpenses = allExpenses.where((e) => e.timestamp.year == selectedYear).toList();
        final yearRevenues = allRevenues.where((r) => r.timestamp.year == selectedYear).toList();

        // Calculate totals
        final totalExpenses = yearExpenses.fold(0.0, (sum, e) => sum + e.amount);
        final totalIncome = yearRevenues.fold(0.0, (sum, r) => sum + r.amount);
        final netCashFlow = totalIncome - totalExpenses;

        // Group by category
        final Map<ExpenseCategory, double> expensesByCategory = {};
        for (final e in yearExpenses) {
          expensesByCategory[e.category] = (expensesByCategory[e.category] ?? 0) + e.amount;
        }

        final Map<IncomeCategory, double> incomeByCategory = {};
        for (final r in yearRevenues) {
          incomeByCategory[r.category] = (incomeByCategory[r.category] ?? 0) + r.amount;
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(selectedYear),
              const SizedBox(height: 24),
              
              _buildSection(
                title: 'TOTAL INCOME',
                amount: totalIncome,
                color: Colors.green,
              ),
              const SizedBox(height: 12),
              _buildIncomeBreakdown(incomeByCategory),
              
              const Divider(height: 40),
              
              _buildSection(
                title: 'TOTAL EXPENSES',
                amount: totalExpenses,
                color: Colors.red,
              ),
              const SizedBox(height: 12),
              _buildExpenseBreakdown(expensesByCategory),
              
              const Divider(height: 40),
              
              _buildSection(
                title: 'NET CASH FLOW',
                amount: netCashFlow,
                color: netCashFlow >= 0 ? Colors.green : Colors.red,
              ),
              const SizedBox(height: 8),
              Text(
                netCashFlow >= 0 ? 'Surplus' : 'Deficit',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
              
              const SizedBox(height: 40),
              _buildDisclaimerSection(),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectYear() async {
    final picked = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Year'),
          content: SizedBox(
            width: 300,
            height: 300,
            child: YearPicker(
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
              selectedDate: DateTime(selectedYear),
              onChanged: (DateTime dateTime) {
                Navigator.pop(context, dateTime.year);
              },
            ),
          ),
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        selectedYear = picked;
      });
    }
  }

  Widget _buildHeader(int year) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Text(
            'ANNUAL FINANCIAL REPORT',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Year: $year',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required double amount,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.3), width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'RM ${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeBreakdown(Map<IncomeCategory, double> categories) {
    if (categories.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: Text('No data', style: TextStyle(color: Colors.grey)),
      );
    }

    return Column(
      children: categories.entries.map((entry) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Icon(entry.key.icon),
            title: Text(entry.key.label),
            trailing: Text(
              'RM ${entry.value.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildExpenseBreakdown(Map<ExpenseCategory, double> categories) {
    if (categories.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: Text('No data', style: TextStyle(color: Colors.grey)),
      );
    }

    return Column(
      children: categories.entries.map((entry) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Icon(entry.key.icon),
            title: Text(entry.key.label),
            trailing: Text(
              'RM ${entry.value.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDisclaimerSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DISCLAIMER',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '• This report is for personal financial tracking only.\n'
            '• Amounts shown are based on your recorded transactions.\n'
            '• Not intended as tax advice or official documentation.\n'
            '• For tax filing, consult with a qualified professional.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  void _shareReport(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share feature coming soon!')),
    );
  }
}