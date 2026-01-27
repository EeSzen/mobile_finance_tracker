import 'dart:async';

import 'package:fintrack/components/bottom_nav.dart';
import 'package:fintrack/ui/auth/auth_screen.dart';
import 'package:fintrack/ui/history/history_screen.dart';
import 'package:fintrack/ui/home_screen.dart';
import 'package:fintrack/ui/auth/login_screen.dart';
import 'package:fintrack/ui/auth/register_screen.dart';
import 'package:fintrack/ui/manage/add/add_expense_screen.dart';
import 'package:fintrack/ui/manage/add/add_revenue_screen.dart';
import 'package:fintrack/ui/manage/edit/edit_expense_screen.dart';
import 'package:fintrack/ui/manage/edit/edit_revenue_screen.dart';
import 'package:fintrack/ui/profile/profile_screen.dart';
import 'package:fintrack/ui/reports/summary_screen.dart';
import 'package:fintrack/ui/stats/stats_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}


class Nav {
  static const initial = "/auth";

  static final router = GoRouter(
    initialLocation: initial,
    refreshListenable: GoRouterRefreshStream(
      FirebaseAuth.instance.authStateChanges(),
    ),
    redirect: (context, state) {
      final user = FirebaseAuth.instance.currentUser;
      final loggingIn = state.matchedLocation.startsWith('/auth') ||
          state.matchedLocation.startsWith('/login') ||
          state.matchedLocation.startsWith('/register');

      if (user == null && !loggingIn) {
        return '/auth';
      }

      if (user != null && loggingIn) {
        return '/home';
      }

      return null;
    },
    routes: [
      // ---------- SHELL WITH BOTTOM NAV ----------
      ShellRoute(
        builder: (context, state, child) {
          return BottomNav(child: child);
        },
        routes: [
          GoRoute(
            path: "/home",
            name: Screen.home.name,
            builder: (context, state) => HomeScreen(),
          ),
          GoRoute(
            path: "/stats",
            name: Screen.stats.name,
            builder: (context, state) => const StatsScreen(),
          ),
          GoRoute(
            path: "/history",
            name: Screen.history.name,
            builder: (context, state) => HistoryScreen(),
          ),
          GoRoute(
            path: "/profile",
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),

      // ---------- AUTH (NO BOTTOM NAV) ----------
      GoRoute(
        path: "/auth",
        name: Screen.auth.name,
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: "/login",
        name: Screen.login.name,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: "/register",
        name: Screen.register.name,
        builder: (context, state) => const RegisterScreen(),
      ),


      // ------------ Manage (No Bottom Nav)----------------
      GoRoute(
        path: "/add_expense",
        name: Screen.add_expense.name,
        builder: (context, state) => const AddExpenseScreen(),
      ),
      GoRoute(
        path: "/add_revenue",
        name: Screen.add_revenue.name,
        builder: (context, state) => const AddRevenueScreen(),
      ),

      GoRoute(
        path: "/edit_expense/:id",
        name: Screen.edit_expense.name,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return EditExpenseScreen(expenseId: id);
        },
      ),
      GoRoute(
        path: "/edit_revenue/:id",
        name: Screen.edit_revenue.name,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return EditRevenueScreen(revenueId: id);
        },
      ),
      GoRoute(
        path: "/annual_summary",
        name: Screen.annual_summary.name,
        builder: (context, state) => const AnnualSummaryScreen(),
      ),
    ],
  );
}

enum Screen {
  home,
  login,
  register,
  auth,
  profile,
  add_expense,
  add_revenue,
  stats,
  history,
  edit_expense,
  edit_revenue, 
  annual_summary,   
}