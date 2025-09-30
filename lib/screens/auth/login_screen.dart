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
  bool _isPasswordObscured = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void toggleScreens() {
    setState(() {
      _showRegisterPage = !_showRegisterPage;
    });
  }

  Future<void> _signIn() async {
    final message = await _authService.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (message != 'Success' && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message ?? 'Email atau password salah')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showRegisterPage) {
      return RegisterScreen(showLoginPage: toggleScreens);
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(hintText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _isPasswordObscured,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordObscured ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordObscured = !_isPasswordObscured;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _signIn,
                    child: const Text('Login'),
                  ),
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
      ),
    );
  }
}