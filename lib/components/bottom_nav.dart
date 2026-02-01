import "package:fintrack/navigation/nav.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";

class BottomNav extends StatelessWidget {
  final Widget child;

  const BottomNav({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;

    Color iconColor(String path) =>
        location == path ? Colors.white : Colors.white54;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: child,

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        elevation: 0,
        shape: CircleBorder(),
        onPressed: () {
          showModalBottomSheet(
            backgroundColor: Colors.black,
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (_) => Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: _AddActionTile(
                        icon: Icons.remove_circle_outline,
                        label: "Expense",
                        onTap: () {
                          Navigator.pop(context);
                          context.pushNamed(Screen.add_expense.name);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: _AddActionTile(
                        icon: Icons.add_circle_outline,
                        label: "Income",
                        onTap: () {
                          Navigator.pop(context);
                          context.pushNamed(Screen.add_revenue.name);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomAppBar(
        color: Colors.black,
        shape: const CircularNotchedRectangle(),
        notchMargin: 5,
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              Expanded(
                child: IconButton(
                  icon: Icon(Icons.home_filled, color: iconColor("/home")),
                  onPressed: () => context.go("/home"),
                ),
              ),
              Expanded(
                child: IconButton(
                  icon: Icon(Icons.dashboard, color: iconColor("/history")),
                  onPressed: () => context.go("/history"),
                ),
              ),
              const Spacer(),
              Expanded(
                child: IconButton(
                  icon: Icon(
                    Icons.candlestick_chart,
                    color: iconColor("/stats"),
                  ),
                  onPressed: () => context.go("/stats"),
                ),
              ),
              Expanded(
                child: IconButton(
                  icon: Icon(Icons.person, color: iconColor("/profile")),
                  onPressed: () => context.go("/profile"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Mini card for bottom Modal
class _AddActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _AddActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          border: Border.all(color: Colors.black, width: 3.0),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
