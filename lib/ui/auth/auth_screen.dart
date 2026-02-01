import 'package:fintrack/navigation/nav.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  void _navToLogin() async {
    await context.pushNamed(Screen.login.name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/fintrack_logo.png"),
            fit: BoxFit.cover,
            opacity: 0.1
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "FinTrack",
              style: TextStyle(fontSize: 44.0, fontWeight: FontWeight.w900),
            ),
            Text("Your personal finance tracker"),
            SizedBox(height: 20.0),
            FilledButton(
              onPressed: () => {_navToLogin()},
              child: Text("Let's start"),
            ),
          ],
        ),
      ),
    );
  }
}
