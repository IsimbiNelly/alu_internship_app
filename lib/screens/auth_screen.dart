import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart' as app_auth;
import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  String selectedRole = 'student';

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();

  Future<void> submit() async {
    final auth = Provider.of<app_auth.AuthProvider>(context, listen: false);
    bool success;

    if (isLogin) {
      success = await auth.login(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
    } else {
      success = await auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        name: nameController.text.trim(),
        role: selectedRole,
      );
    }

    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<app_auth.AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text(isLogin ? 'Login' : 'Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!isLogin)
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                ),
              const SizedBox(height: 10),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
              ),
              const SizedBox(height: 10),
              if (!isLogin)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ChoiceChip(
                      label: const Text('Student'),
                      selected: selectedRole == 'student',
                      onSelected: (_) => setState(() => selectedRole = 'student'),
                    ),
                    const SizedBox(width: 10),
                    ChoiceChip(
                      label: const Text('Startup'),
                      selected: selectedRole == 'startup',
                      onSelected: (_) => setState(() => selectedRole = 'startup'),
                    ),
                  ],
                ),
              const SizedBox(height: 20),
              if (auth.errorMessage != null)
                Text(auth.errorMessage!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 10),
              auth.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: submit,
                      child: Text(isLogin ? 'Login' : 'Sign Up'),
                    ),
              TextButton(
                onPressed: () => setState(() => isLogin = !isLogin),
                child: Text(isLogin
                    ? "Don't have an account? Sign Up"
                    : "Already have an account? Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}