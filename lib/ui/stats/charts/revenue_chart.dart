import 'package:fintrack/data/enums/income_category.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class RevenueChart extends StatelessWidget {
  final Map<IncomeCategory, double> totals;
  final Map<IncomeCategory, int> counts;

  const RevenueChart({super.key, required this.totals, required this.counts});

  @override
  Widget build(BuildContext context) {
    if (totals.isEmpty) {
      return const Center(child: Text("No income data available"));
    }

    final total = totals.values.reduce((a, b) => a + b);

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: totals.entries.map((entry) {
                final percentage = (entry.value / total) * 100;
                return PieChartSectionData(
                  value: entry.value,
                  title: '${percentage.toStringAsFixed(1)}%',
                  color: _getCategoryColor(entry.key),
                  radius: 75,
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
        const SizedBox(height: 30),
        
        Expanded(
        child: ListView(
          children: totals.entries.map((entry) {
            final count = counts[entry.key] ?? 0;  // Get count for this category
            
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: _getCategoryColor(entry.key),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(entry.key.icon, size: 24, color: _getCategoryColor(entry.key)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.key.label,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "$count transaction${count != 1 ? 's' : ''}",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      "RM${entry.value.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
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