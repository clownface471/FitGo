import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream untuk memantau status login user
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Fungsi Sign Up
  Future<String?> signUp({required String email, required String password}) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return "Success";
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // Fungsi Sign In
  Future<String?> signIn({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return "Success";
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // Fungsi Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}