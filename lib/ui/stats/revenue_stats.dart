import "package:fintrack/data/enums/income_category.dart";
import "package:fintrack/data/model/revenue.dart";
import "package:fintrack/data/repo/services/revenue_service.dart";
import "package:fintrack/ui/stats/charts/revenue_chart.dart";
import "package:flutter/material.dart";

class RevenueStats extends StatefulWidget {
  const RevenueStats({super.key});

  @override
  State<RevenueStats> createState() => _RevenueStatsState();
}

class _RevenueStatsState extends State<RevenueStats> {
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
    return StreamBuilder<List<Revenue>>(
      stream: RevenueService().getRevenuesStream(),
      builder: (context, snap) {
        if (snap.hasError) {
          return Center(
            child: Text("Error: ${snap.error}\n${snap.stackTrace}"),
          );
        }

        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final allRevenues = snap.data!;

        // Filter revenues based on selected period
        final filteredRevenues = allRevenues.where((revenue) {
          if (showMonthly) {
            return revenue.timestamp.year == selectedDate.year &&
                  revenue.timestamp.month == selectedDate.month;
          } else {
            return revenue.timestamp.year == selectedDate.year;
          }
        }).toList();

        final Map<IncomeCategory, double> totals = {};
        final Map<IncomeCategory, int> counts = {}; 

        for (final e in filteredRevenues) {
          totals[e.category] = (totals[e.category] ?? 0) + e.amount;
          counts[e.category] = (counts[e.category] ?? 0) + 1;
        }

        return RevenueChart(totals: totals, counts: counts);
      },
    );
  }

  // Show Month Picker
  Future<void> _selectMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
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
