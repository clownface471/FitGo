import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../main/main_screen.dart';
import 'login_screen.dart';
import '../onboarding/goal_selection_screen.dart'; 
import '../../utils/firestore_service.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const LoginScreen();
        }

        return FutureBuilder<bool>(
          future: FirestoreService().hasCompletedOnboarding(snapshot.data!.uid),
          builder: (context, onboardingSnapshot) {
            if (onboardingSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }
            if (onboardingSnapshot.data == true) {
              return const MainScreen();
            } else {
              return const GoalSelectionScreen();
            }
          },
        );
      },
    );
  }
}