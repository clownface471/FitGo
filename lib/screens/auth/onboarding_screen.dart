import 'package:flutter/material.dart';
import 'login_screen.dart'; // Akan kita buat light mode-nya
import '../../utils/theme.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(flex: 2),
            const CircleAvatar(
              radius: 100,
              backgroundColor: primaryColor,
              child: Text(
                'PHOTO\nPROFILE',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: darkTextColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 40),
            Text('Welcome To FitGo.', style: Theme.of(context).textTheme.headlineMedium),
            const Spacer(flex: 3),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ElevatedButton(
                onPressed: () {
                   // Arahkan ke login screen saat ditekan
                   Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                },
                child: const Text('Login with Apple'),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  side: const BorderSide(color: primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                   Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                },
                child: const Text('Login with Google', style: TextStyle(color: primaryColor)),
              ),
            ),
            const Spacer(flex: 1),
          ],
        ),
      ),
    );
  }
}