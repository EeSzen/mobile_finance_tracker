import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
        onPressed: () => {}
        //  context.go('/add')
        ,
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
                  icon: Icon(Icons.home_filled, color: iconColor('/home')),
                  onPressed: () => context.go('/home'),
                ),
              ),
              Expanded(
                child: IconButton(
                  icon: Icon(Icons.dashboard, color: iconColor('/stats')),
                  onPressed: () => context.go('/home'),
                ),
              ),
              const Spacer(),
              Expanded(
                child: IconButton(
                  icon: Icon(Icons.candlestick_chart, color: iconColor('/market')),
                  onPressed: () => context.go('/home'),
                ),
              ),
              Expanded(
                child: IconButton(
                  icon: Icon(Icons.person, color: iconColor('/profile')),
                  onPressed: () => context.go('/profile'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
