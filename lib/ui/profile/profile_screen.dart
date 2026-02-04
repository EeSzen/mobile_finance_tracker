import 'package:fintrack/data/model/users.dart';
import 'package:fintrack/data/repo/user_repo.dart';
import 'package:fintrack/data/repo/services/expense_service.dart';
import 'package:fintrack/data/repo/services/revenue_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final repo = UserRepo();
  final _expenseService = ExpenseService();
  final _revenueService = RevenueService();
  AppUser? profile;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      repo.getUser(user.uid).then((data) {
        setState(() => profile = data);
      });
    }
  }

  Future<void> _editUsername() async {
    final controller = TextEditingController(text: profile!.displayName);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Username'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Username',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null &&
        result.trim().isNotEmpty &&
        result != profile!.displayName) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          await repo.updateDisplayName(user.uid, result.trim());
          final updatedProfile = await repo.getUser(user.uid);
          setState(() => profile = updatedProfile);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Username updated successfully')),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to update username: $e')),
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (profile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<Map<String, dynamic>>(
        stream: Rx.zip2(
          _expenseService.getExpensesStream(),
          _revenueService.getRevenuesStream(),
          (expenses, revenues) => {"expenses": expenses, "revenues": revenues},
        ),
        builder: (context, snapshot) {
          double monthlySpending = 0;
          double monthlyIncome = 0;

          if (snapshot.hasData) {
            final now = DateTime.now();
            final currentMonth = now.month;
            final currentYear = now.year;

            final expenses = snapshot.data!["expenses"] as List;
            final revenues = snapshot.data!["revenues"] as List;

            monthlySpending = expenses
                .where(
                  (e) =>
                      e.timestamp.month == currentMonth &&
                      e.timestamp.year == currentYear,
                )
                .fold(0.0, (sum, e) => sum + e.amount);

            monthlyIncome = revenues
                .where(
                  (r) =>
                      r.timestamp.month == currentMonth &&
                      r.timestamp.year == currentYear,
                )
                .fold(0.0, (sum, r) => sum + r.amount);
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              profile!.displayName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.white70,
                              size: 20,
                            ),
                            onPressed: _editUsername,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        profile!.email,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                IntrinsicHeight(
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: "This Month's Income",
                          amount: monthlyIncome,
                          icon: Icons.trending_up,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: _StatCard(
                          title: "This Month's Expense",
                          amount: monthlySpending,
                          icon: Icons.trending_down,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final double amount;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              "RM${amount.toStringAsFixed(2)}",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
