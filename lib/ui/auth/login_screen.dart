import 'package:fintrack/auth/auth.dart';
import 'package:fintrack/auth/user_service.dart';
import 'package:fintrack/navigation/nav.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;
  bool gLoading = false;

  void login() async {
    setState(() => loading = true);
    try {
      final user = await signIn(
        emailController.text.trim(),
        passwordController.text,
      );
      if (user != null) {
        await createUserIfNotExists(user);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  void loginWithGoogle() async {
    setState(() => gLoading = true);
    try {
      final user = await signInWithGoogle();
      if (user != null) {
        await createUserIfNotExists(user);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google Sign-In failed: $e')),
      );
    } finally {
      setState(() => gLoading = false);
    }
  }


  void _navToSignUp() async {
    await context.pushNamed(Screen.register.name);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login Screen"),
        // backgroundColor: Colors.blue,
      ),
      body: Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 16.0),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Enter Email"
                  ),
                ),
                SizedBox(height: 16.0),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Enter Password"
                  ), obscureText: true
                ),
                SizedBox(height: 16.0),
                FilledButton(
                  onPressed: () => {login()},
                  child: 
                  loading ? CircularProgressIndicator() : Text("Login")
                ),
                SizedBox(height: 16.0),
                Divider(),
                SizedBox(height: 16.0),
                OutlinedButton(
                  onPressed: () => {loginWithGoogle()}, 
                  child: Padding(
                    padding: EdgeInsetsGeometry.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.g_mobiledata_outlined, size: 40.0,),
                        gLoading ? CircularProgressIndicator() : Text("Login with Google")
                      ]
                    ),
                  )
                ),
                SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account yet?"),
                    TextButton(
                      onPressed: (() => _navToSignUp()), 
                      child: Text("Sign Up"),
                    )
                  ],
                )
            ],
          ),
      )
    );
  }
}