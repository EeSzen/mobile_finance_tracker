import 'package:fintrack/ui/home_screen.dart';
import 'package:go_router/go_router.dart';

class Nav {
  static const initial = "/home";
  static final routes = [
    GoRoute(
      path: "/home",
      name: Screen.home.name,
      builder: (context, state) => const HomeScreen(),
    ),
    // GoRoute(
    //   path: "/add",
    //   name: Screen.add.name,
    //   builder: (context, state) => const AddTaskScreen(),
    // ),
    // GoRoute(
    //   path: "/update/:id",
    //   name: Screen.update.name,
    //   builder: (context, state) => UpdateTaskScreen(
    //     id: state.pathParameters["id"]!
    //   ),
    // )
  ];
}

enum Screen{
  home , add, update
}