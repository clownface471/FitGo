import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/daily_progress_model.dart';
import '../models/diet_plan_model.dart';
import '../models/exercise_model.dart';
import '../models/motivation_model.dart';
import '../models/recipe_model.dart';
import '../models/user_model.dart';
import '../models/workout_history_model.dart';
import '../models/workout_plan_model.dart';
import '../utils/auth_service.dart';
import '../utils/firestore_service.dart';

// Service Providers
final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final firestoreServiceProvider = Provider<FirestoreService>((ref) => FirestoreService());

// Auth State Provider
final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

// User Data Provider
final userProvider = FutureProvider<UserModel?>((ref) async {
  final user = ref.watch(authStateChangesProvider).asData?.value;
  if (user != null) {
    return ref.watch(firestoreServiceProvider).getUserData(user.uid);
  }
  return null;
});

// Local Data Provider for Exercises
final exercisesProvider = FutureProvider<List<Exercise>>((ref) {
  return ref.watch(firestoreServiceProvider).getLocalExercises();
});

// Local Data Provider for Motivations
final motivationsProvider = FutureProvider<List<Motivation>>((ref) {
    return ref.watch(firestoreServiceProvider).getMotivations();
});

// Firestore-based Providers
final dailyProgressProvider = FutureProvider<DailyProgress>((ref) async {
  final user = await ref.watch(userProvider.future);
  if (user != null) {
    return ref.watch(firestoreServiceProvider).getDailyProgress(user.uid);
  }
  return DailyProgress(date: DateTime.now());
});

final recommendedPlanProvider = FutureProvider<WorkoutPlan?>((ref) async {
  final user = await ref.watch(userProvider.future);
  if (user != null && user.goal != null && user.level != null) {
    return ref
        .watch(firestoreServiceProvider)
        .getRecommendedPlan(user.goal!, user.level!);
  }
  return null;
});

final allRecipesProvider = FutureProvider<List<Recipe>>((ref) {
  return ref.watch(firestoreServiceProvider).getAllRecipes();
});

final recommendedDietPlanProvider = FutureProvider<DietPlan?>((ref) async {
  final user = await ref.watch(userProvider.future);
  if (user != null && user.goal != null) {
    return ref.watch(firestoreServiceProvider).getRecommendedDietPlan(user.goal!);
  }
  return null;
});

final workoutHistoryProvider = FutureProvider<List<WorkoutHistory>>((ref) async {
  final user = await ref.watch(userProvider.future);
  if (user != null) {
    return ref.watch(firestoreServiceProvider).getWorkoutHistory(user.uid);
  }
  return [];
});

// Combined Providers for Screens
final homeScreenDataProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final user = await ref.watch(userProvider.future);
  final plan = await ref.watch(recommendedPlanProvider.future);
  final exercises = await ref.watch(exercisesProvider.future);
  final progress = await ref.watch(dailyProgressProvider.future);

  if (user == null) {
    throw Exception("Pengguna tidak ditemukan.");
  }

  return {
    'user': user,
    'plan': plan,
    'exercises': exercises,
    'progress': progress,
  };
});

final dietScreenDataProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final user = await ref.watch(userProvider.future);
  final recipes = await ref.watch(allRecipesProvider.future);
  final progress = await ref.watch(dailyProgressProvider.future);
  final dietPlan = await ref.watch(recommendedDietPlanProvider.future);

  if (user == null) {
    throw Exception("Data user tidak lengkap");
  }

  return {
    'user': user,
    'recipes': recipes,
    'progress': progress,
    'plan': dietPlan,
  };
});