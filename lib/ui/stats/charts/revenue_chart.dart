import 'package:fintrack/data/enums/income_category.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class RevenueChart extends StatelessWidget {
  final Map<IncomeCategory, double> totals;

  const RevenueChart({super.key, required this.totals});

  @override
  Widget build(BuildContext context) {
    if (totals.isEmpty) {
      return const Center(child: Text("No income data available"));
    }

    final total = totals.values.reduce((a, b) => a + b);

    return Column(
      children: [
        SizedBox(
          height: 250,
          child: PieChart(
            PieChartData(
              sections: totals.entries.map((entry) {
                final percentage = (entry.value / total) * 100;
                return PieChartSectionData(
                  value: entry.value,
                  title: '${percentage.toStringAsFixed(1)}%',
                  color: _getCategoryColor(entry.key),
                  radius: 100,
                  titleStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }).toList(),
              sectionsSpace: 2,
              centerSpaceRadius: 40,
            ),
          ),
        ),
        const SizedBox(height: 20),
        
        Expanded(
          child: ListView(
            children: totals.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: _getCategoryColor(entry.key),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(entry.key.icon, size: 20),
                    const SizedBox(width: 8),
                    Expanded(child: Text(entry.key.label)),
                    Text(
                      "RM${entry.value.toStringAsFixed(2)}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor(IncomeCategory category) {
    switch (category) {
      case IncomeCategory.salary:
        return Colors.green;
      case IncomeCategory.freelance:
        return Colors.blue;
      case IncomeCategory.investment:
        return Colors.purple;
      case IncomeCategory.other:
        return Colors.grey;
    }
  }
}