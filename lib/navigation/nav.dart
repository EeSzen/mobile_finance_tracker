import 'dart:async';

import 'package:fintrack/components/bottom_nav.dart';
import 'package:fintrack/ui/auth/auth_screen.dart';
import 'package:fintrack/ui/home_screen.dart';
import 'package:fintrack/ui/auth/login_screen.dart';
import 'package:fintrack/ui/auth/register_screen.dart';
import 'package:fintrack/ui/profile/profile_screen.dart';
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
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: "/stats",
            builder: (context, state) => const Placeholder(),
          ),
          GoRoute(
            path: "/market",
            builder: (context, state) => const Placeholder(),
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
    ],
  );
}

enum Screen{
  home , login, register, auth, profile
}