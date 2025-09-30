// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/exercise_model.dart';
import '../models/user_model.dart';
import '../models/workout_plan_model.dart';
import '../models/workout_history_model.dart';
import '../models/diet_plan_model.dart';
import '../models/recipe_model.dart';
import '../models/motivation_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print("Error getting user data: $e");
      return null;
    }
  }

  Future<void> createUser({
    required String uid,
    required String email,
  }) async {
    await _db.collection('users').doc(uid).set({
      'uid': uid,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
      'onboardingCompleted': false,
      'currentDay': 1,
    });
  }

  Future<void> advanceToNextDay(String uid) async {
    await _db.collection('users').doc(uid).update({
      'currentDay': FieldValue.increment(1),
    });
  }

  Future<void> updateUserOnboardingData({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    await _db.collection('users').doc(uid).set(data, SetOptions(merge: true));
  }

  Future<bool> hasCompletedOnboarding(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      return doc.data()?['onboardingCompleted'] ?? false;
    }
    return false;
  }

  Future<List<Exercise>> getExercises() async {
    try {
      QuerySnapshot snapshot = await _db.collection('exercises').get();
      final exercises = snapshot.docs.map((doc) {
        return Exercise.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
      return exercises;
    } catch (e) {
      print("Error fetching exercises: $e");
      return [];
    }
  }

  Future<WorkoutPlan?> getRecommendedPlan(String goal, String level) async {
    try {
      final querySnapshot = await _db.collection('workoutPlans')
          .where('goal', isEqualTo: goal)
          .where('level', isEqualTo: level)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return WorkoutPlan.fromFirestore(querySnapshot.docs.first);
      }
      return null;
    } catch (e) {
      print("Error getting recommended plan: $e");
      return null;
    }
  }
    Future<void> addWorkoutHistory({
    required String uid,
    required String planName,
    required String workoutName,
    required int dayCompleted,
  }) async {
    try {
      await _db.collection('users').doc(uid).collection('workoutHistory').add({
        'planName': planName,
        'workoutName': workoutName,
        'dayCompleted': dayCompleted,
        'completedDate': FieldValue.serverTimestamp(), 
      });
    } catch (e) {
      print("Error adding workout history: $e");
    }
  }

  Future<List<WorkoutHistory>> getWorkoutHistory(String uid) async {
    try {
      final snapshot = await _db
          .collection('users')
          .doc(uid)
          .collection('workoutHistory')
          .orderBy('completedDate', descending: true)
          .get();

      if (snapshot.docs.isEmpty) {
        return [];
      }
      
      return snapshot.docs.map((doc) => WorkoutHistory.fromFirestore(doc)).toList();
    } catch (e) {
      print("Error fetching workout history: $e");
      return [];
    }
  }
  Future<DietPlan?> getRecommendedDietPlan(String goal) async {
    try {
      final query = await _db.collection('dietPlans').where('goal', isEqualTo: goal).limit(1).get();
      if (query.docs.isNotEmpty) {
        return DietPlan.fromFirestore(query.docs.first);
      }
      return null;
    } catch (e) {
      print("Error getting diet plan: $e");
      return null;
    }
  }

  Future<List<Recipe>> getAllRecipes() async {
    try {
      final snapshot = await _db.collection('recipes').get();
      return snapshot.docs.map((doc) => Recipe.fromFirestore(doc)).toList();
    } catch(e) {
      print("Error getting all recipes: $e");
      return [];
    }
  }
  Future<List<Motivation>> getMotivations() async {
  try {
    final snapshot = await _db.collection('motivations').get();
    return snapshot.docs.map((doc) => Motivation.fromFirestore(doc)).toList();
  } catch (e) {
    print("Error getting motivations: $e");
    return [];
  }
}
}
