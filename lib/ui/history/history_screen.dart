import "package:fintrack/navigation/nav.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:rxdart/rxdart.dart";

import "package:fintrack/data/enums/expenses_category.dart";
import "package:fintrack/data/enums/income_category.dart";
import "package:fintrack/data/model/expense.dart";
import "package:fintrack/data/model/history_item.dart";
import "package:fintrack/data/model/revenue.dart";
import "package:fintrack/data/repo/services/expense_service.dart";
import "package:fintrack/data/repo/services/revenue_service.dart";

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // final repo = TransactionRepo();
  late Future<List<HistoryItem>> future;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("History"),
        actions: [
          IconButton(
            icon: const Icon(Icons.assessment),
            tooltip: 'Annual Summary',
            onPressed: () {
              context.pushNamed(Screen.annual_summary.name);
            },
          ),
        ],
      ),
      body: const _HistoryBody(),
    );
  }
}

class _HistoryBody extends StatefulWidget {
  const _HistoryBody();

  @override
  State<_HistoryBody> createState() => _HistoryBodyState();
}

class _HistoryBodyState extends State<_HistoryBody> {
  final _expenseService = ExpenseService();
  final _revenueService = RevenueService();

  String query = "";
  bool showExpenseFilter = true;
  bool showIncomeFilter = true;
  String sortOption = "date_desc";
  List<String> selectedCategories = [];
  DateTime? startDate;
  DateTime? endDate;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>>(
      // zips both streams together //
      stream: Rx.combineLatest2(
        _expenseService.getExpensesStream(),
        _revenueService.getRevenuesStream(),
        (expenses, revenues) => {"expenses": expenses, "revenues": revenues},
      ),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final expenses = snap.data!["expenses"] as List<Expense>;
        final revenues = snap.data!["revenues"] as List<Revenue>;

        var items = _merge(expenses, revenues);

        // Search
        if (query.isNotEmpty) {
          items = items
              .where(
                (e) =>
                    e.title.toLowerCase().contains(query.toLowerCase()) ||
                    e.subtitle.toLowerCase().contains(query.toLowerCase()),
              )
              .toList();
        }

        // Filter
        if (showExpenseFilter != showIncomeFilter) {
          items = items.where((e) => e.isExpense == showExpenseFilter).toList();
        }

        // Category
        if (selectedCategories.isNotEmpty) {
          items = items
              .where((e) => selectedCategories.contains(e.title))
              .toList();
        }

        // Date
        if (startDate != null || endDate != null) {
          final start = startDate == null
              ? null
              : DateTime(startDate!.year, startDate!.month, startDate!.day);

          final end = endDate == null
              ? null
              : DateTime(
                  endDate!.year,
                  endDate!.month,
                  endDate!.day,
                  23,
                  59,
                  59,
                  999,
                );

          items = items.where((e) {
            final t = e.time;
            if (start != null && t.isBefore(start)) return false;
            if (end != null && t.isAfter(end)) return false;
            return true;
          }).toList();
        }

        // Sort
        switch (sortOption) {
          case "date_asc":
            items.sort((a, b) => a.time.compareTo(b.time));
            break;
          case "date_desc":
            items.sort((a, b) => b.time.compareTo(a.time));
            break;
          case "amount_asc":
            items.sort((a, b) => a.amount.compareTo(b.amount));
            break;
          case "amount_desc":
            items.sort((a, b) => b.amount.compareTo(a.amount));
            break;
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (val) => setState(() => query = val),
                      decoration: InputDecoration(
                        hintText: "Search transactions...",
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      child: Text(
                        startDate == null
                            ? "Start Date"
                            : _formatDate(startDate),
                      ),
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: startDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: endDate ?? DateTime.now(),
                        );
                        if (date != null) setState(() => startDate = date);
                      },
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text("-"),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      child: Text(
                        endDate == null ? "End Date" : _formatDate(endDate),
                      ),
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: endDate ?? (startDate ?? DateTime.now()),
                          firstDate: startDate ?? DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) setState(() => endDate = date);
                      },
                    ),
                  ),
                  if (startDate != null || endDate != null)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() {
                        startDate = null;
                        endDate = null;
                      }),
                    ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text("Expense"),
                        selected: showExpenseFilter,
                        onSelected: (val) =>
                            setState(() => showExpenseFilter = val),
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text("Income"),
                        selected: showIncomeFilter,
                        onSelected: (val) =>
                            setState(() => showIncomeFilter = val),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: PopupMenuButton<String>(
                    onSelected: (val) => setState(() => sortOption = val),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: "date_desc",
                        child: Text("Newest"),
                      ),
                      const PopupMenuItem(
                        value: "date_asc",
                        child: Text("Oldest"),
                      ),
                      const PopupMenuItem(
                        value: "amount_desc",
                        child: Text("Highest"),
                      ),
                      const PopupMenuItem(
                        value: "amount_asc",
                        child: Text("Lowest"),
                      ),
                    ],
                    child: Chip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            sortOption == "date_desc"
                                ? "Newest"
                                : sortOption == "date_asc"
                                ? "Oldest"
                                : sortOption == "amount_desc"
                                ? "Highest"
                                : "Lowest",
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_drop_down, size: 18),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // list of data
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No transactions found',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try adjusting your filters',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final item = items[i];
                        return InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () {
                            if (item.id.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Cannot edit this item'),
                                ),
                              );
                              return;
                            }

                            if (item.isExpense) {
                              context.pushNamed(
                                Screen.edit_expense.name,
                                pathParameters: {'id': item.id},
                              );
                            } else {
                              context.pushNamed(
                                Screen.edit_revenue.name,
                                pathParameters: {'id': item.id},
                              );
                            }
                          },
                          child: _HistoryCard(item: item),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

String _formatDate(DateTime? dt) {
  if (dt == null) return "";
  return "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}";
}

List<HistoryItem> _merge(List<Expense> expenses, List<Revenue> revenues) {
  final items = <HistoryItem>[];

  for (final e in expenses) {
    items.add(
      HistoryItem(
        id: e.docId ?? '',
        time: e.timestamp,
        title: e.category.label,
        subtitle: e.note,
        amount: e.amount,
        isExpense: true,
        icon: e.category.icon,
      ),
    );
  }

  for (final r in revenues) {
    items.add(
      HistoryItem(
        id: r.docId ?? '',
        time: r.timestamp,
        title: r.category.label,
        subtitle: r.source,
        amount: r.amount,
        isExpense: false,
        icon: r.category.icon,
      ),
    );
  }

  items.sort((a, b) => b.time.compareTo(a.time));
  return items;
}

class _HistoryCard extends StatelessWidget {
  final HistoryItem item;

  const _HistoryCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final color = item.isExpense ? Colors.red : Colors.green;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.15),
              child: Icon(item.icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "${item.isExpense ? "-" : "+"}RM${item.amount.toStringAsFixed(2)}",
                  style: TextStyle(fontWeight: FontWeight.bold, color: color),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(item.time),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return "";
    return "${dt.day.toString().padLeft(2, "0")}/${dt.month.toString().padLeft(2, "0")}/${dt.year}";
  }
}
