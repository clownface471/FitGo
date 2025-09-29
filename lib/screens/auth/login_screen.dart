import 'package:flutter/material.dart';
import '../../utils/auth_service.dart';
import '../../utils/theme.dart'; 
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _showRegisterPage = false;

  void toggleScreens() {
    setState(() {
      _showRegisterPage = !_showRegisterPage;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    if (_showRegisterPage) {
      return RegisterScreen(showLoginPage: toggleScreens);
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 64),
                  children: const <TextSpan>[
                    TextSpan(text: 'FitGo'),
                    TextSpan(text: '.', style: TextStyle(color: primaryColor)), 
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text('Login to your account', style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 30),

              TextFormField(controller: _emailController, decoration: const InputDecoration(hintText: 'Email')),
              const SizedBox(height: 16),
              TextFormField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(hintText: 'Password')),
              const Spacer(),

              ElevatedButton(
                onPressed: () async {
                  final message = await _authService.signIn(
                    email: _emailController.text,
                    password: _passwordController.text,
                  );
                  if (message != 'Success' && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(message ?? 'Email atau password salah')),
                    );
                  }
                },
                child: const Text('Login'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: toggleScreens,
                child: const Text("Belum punya akun? Daftar sekarang", style: TextStyle(color: primaryColor)), 
              )
            ],
          ),
        ),
      ),
    );
  }
}