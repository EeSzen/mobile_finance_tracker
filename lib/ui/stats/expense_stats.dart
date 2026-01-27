import "package:fintrack/data/enums/expenses_category.dart";
import "package:fintrack/data/model/expense.dart";
import "package:fintrack/data/repo/services/expense_service.dart";
import "package:fintrack/ui/stats/charts/expense_chart.dart";
import "package:flutter/material.dart";

class ExpenseStats extends StatefulWidget {
  const ExpenseStats({super.key});

  @override
  State<ExpenseStats> createState() => _ExpenseStatsState();
}

class _ExpenseStatsState extends State<ExpenseStats> {
  bool showMonthly = true; // Default to monthly view

  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildPeriodToggle(),
        const SizedBox(height: 16),
        Expanded(child: _buildChart()),
      ],
    );
  }

  Widget _buildPeriodToggle() {
    return Column(
      children: [
        // Keep your existing toggle buttons
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              _toggleButton("Month", showMonthly, () {
                setState(() => showMonthly = true);
              }),
              _toggleButton("Year", !showMonthly, () {
                setState(() => showMonthly = false);
              }),
            ],
          ),
        ),
        
        // NEW: Add date selector row
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              showMonthly 
                ? "${_getMonthName(selectedDate.month)} ${selectedDate.year}"
                : "${selectedDate.year}",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            IconButton(
              icon: Icon(Icons.calendar_month),
              onPressed: showMonthly ? _selectMonth : _selectYear,
              tooltip: "Change Date",
            ),
          ],
        ),
      ],
    );
  }

  String _getMonthName(int month) {
    const months = [
      "January", "February", "March", "April", "May", "June",
      "July", "August", "September", "October", "November", "December"
    ];
    return months[month - 1];
  }

  Widget _toggleButton(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? Colors.black : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChart() {
    return StreamBuilder<List<Expense>>(
      stream: ExpenseService().getExpensesStream(),
      builder: (context, snap) {
        if (snap.hasError) {
          return Center(
            child: Text("Error: ${snap.error}\n${snap.stackTrace}"),
          );
        }

        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final allExpenses = snap.data!;

        // Filter expenses based on selected period
        final filteredExpenses = allExpenses.where((expense) {
          if (showMonthly) {
            return expense.timestamp.year == selectedDate.year &&
                  expense.timestamp.month == selectedDate.month;
          } else {
            return expense.timestamp.year == selectedDate.year;
          }
        }).toList();

        final Map<ExpenseCategory, double> totals = {};
        final Map<ExpenseCategory, int> counts = {};  // NEW: Track counts

        for (final e in filteredExpenses) {
          totals[e.category] = (totals[e.category] ?? 0) + e.amount;
          counts[e.category] = (counts[e.category] ?? 0) + 1;  // NEW: Increment count
        }

        return ExpenseChart(totals: totals, counts: counts);  // NEW: Pass counts
      },
    );
  }

  // Show Month Picker
  Future<void> _selectMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000), // Earliest date you allow
      lastDate: DateTime.now(),
      helpText: "Select Month",
    );
    
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // Show Year Picker
  Future<void> _selectYear() async {
    final picked = await showDialog<DateTime>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Select Year"),
          content: SizedBox(
            width: 300,
            height: 300,
            child: YearPicker(
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
              selectedDate: selectedDate,
              onChanged: (DateTime dateTime) {
                Navigator.pop(context, dateTime);
              },
            ),
          ),
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

}
