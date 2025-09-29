import 'package:flutter/material.dart';
import '../../utils/auth_service.dart';
import '../../utils/theme.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback showLoginPage;
  const RegisterScreen({super.key, required this.showLoginPage});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Buat Akun", style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 40),

              TextFormField(controller: _emailController, decoration: const InputDecoration(hintText: 'Email')),
              const SizedBox(height: 16),
              TextFormField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(hintText: 'Password')),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: () async {
                  final message = await _authService.signUp(
                    email: _emailController.text,
                    password: _passwordController.text,
                  );
                  if (message != 'Success' && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(message ?? 'Gagal membuat akun')),
                    );
                  }
                },
                child: const Text('Register'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: widget.showLoginPage,
                child: const Text("Sudah punya akun? Login di sini", style: TextStyle(color: primaryColor)),
              )
            ],
          ),
        ),
      ),
    );
  }
}