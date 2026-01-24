import 'package:fintrack/data/enums/income_category.dart';
import 'package:fintrack/data/model/revenue.dart';
import 'package:fintrack/data/repo/services/revenue_service.dart';
import 'package:fintrack/ui/stats/charts/revenue_chart.dart';
import 'package:flutter/material.dart';

class RevenueStats extends StatelessWidget {
  const RevenueStats({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Revenue>>(
      stream: RevenueService().getRevenuesStream(),
      builder: (context, snap) {
        if (snap.hasError) {
          return Center(
            child: Text('Error: ${snap.error}\n${snap.stackTrace}'),
          );
        }

        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final revenues = snap.data!;
        final Map<IncomeCategory, double> totals = {};

        for (final r in revenues) {
          totals[r.category] = (totals[r.category] ?? 0) + r.amount;
        }

        // return Text("Hello");
        return RevenueChart(totals: totals);
      },
    );
  }
}
