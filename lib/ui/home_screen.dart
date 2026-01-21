import 'package:fintrack/auth/auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("FinTrack",
        style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout,color: Color.fromARGB(255, 255, 0, 0),),
            onPressed: () {
              signOut();
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _BalanceCard(),
            const SizedBox(height: 16),
            Row(
              children: const [
                Expanded(child: _SummaryCard(title: "Income", amount: 2500, color: Colors.green)),
                SizedBox(width: 16),
                Expanded(child: _SummaryCard(title: "Expense", amount: 1200, color: Colors.red)),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              "Recent Transactions",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(child: _TransactionList()),
          ],
        ),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 0, 0, 0),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text("Total Balance", style: TextStyle(color: Colors.white70)),
          SizedBox(height: 8),
          Text(
            "\$1,300.00",
            style: TextStyle(
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
            "\$${amount.toStringAsFixed(2)}",
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

class _TransactionList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: 5,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.grey.shade200,
            child: const Icon(Icons.shopping_cart, color: Colors.black),
          ),
          title: const Text("Groceries"),
          subtitle: const Text("Jan 19, 2026"),
          trailing: const Text(
            "-\$45.00",
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
        );
      },
    );
  }
}
