import 'package:fintrack/auth/auth.dart';
import 'package:fintrack/auth/user_service.dart';
import 'package:fintrack/navigation/nav.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool loading = false;
  bool gLoading = false;

  void register() async {
    setState(() => loading = true);
    try {
      if (confirmPasswordController.text != passwordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Passwords do not match"))
        );
        setState(() => loading = false);
        return;
      }
      final user = await signUp(emailController.text.trim(), passwordController.text.trim());
      if (user != null) {
        await createUserIfNotExists(user);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registration failed: $e"))
      );
    } finally {
      setState(() => loading = false);
    }
  }

  void continueWithGoogle() async {
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


  void _navToLogin() async {
    await context.pushNamed(Screen.login.name);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Register Screen"),
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
                TextField(
                  controller: confirmPasswordController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Confirm Password"
                  ), obscureText: true
                ),
                SizedBox(height: 16.0),
                FilledButton(
                  onPressed: () => {register()},
                  child: 
                  loading ? CircularProgressIndicator() : Text("Sign Up")
                ),
                SizedBox(height: 16.0),
                Divider(),
                SizedBox(height: 16.0),
                OutlinedButton(
                  onPressed: () => {continueWithGoogle()}, 
                  child: Padding(
                    padding: EdgeInsetsGeometry.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.g_mobiledata_outlined, size: 40.0,),
                        gLoading ? CircularProgressIndicator() : Text("Sign in with Google")
                      ]
                    ),
                  )
                ),
                SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Already have an account?"),
                    TextButton(
                      onPressed: (() => _navToLogin()), 
                      child: Text("Login"),
                    )
                  ],
                )
            ],
          ),
      )
    );
  }
}