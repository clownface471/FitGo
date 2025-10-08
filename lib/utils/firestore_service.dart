// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import '../models/daily_progress_model.dart';
import '../models/diet_plan_model.dart';
import '../models/exercise_model.dart';
import '../models/recipe_model.dart';
import '../models/user_model.dart';
import '../models/user_progress_model.dart';
import '../models/workout_history_model.dart';
import '../models/workout_plan_model.dart';
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

  Future<List<Motivation>> getMotivations() async {
    try {
      final String response = await rootBundle.loadString('assets/data/motivations.json');
      final data = await json.decode(response) as List;
      // Gunakan fromJson karena model kita sudah disesuaikan untuk itu
      return data.map((e) => Motivation.fromJson(e)).toList();
    } catch (e) {
      print("Error loading local motivations: $e");
      return [];
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
      'planStartDate': null,
      'progress': UserProgress().toMap(),
    });
  }

  Future<void> updateUserProgressAfterWorkout(String uid) async {
    final userRef = _db.collection('users').doc(uid);

    await _db.runTransaction((transaction) async {
      final userDoc = await transaction.get(userRef);
      if (!userDoc.exists) return;

      final data = userDoc.data() as Map<String, dynamic>;
      final progress = UserProgress.fromMap(data['progress']);
      final planStartDate = (data['planStartDate'] as Timestamp?)?.toDate();

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      int newStreak = progress.currentStreak;
      
      if (progress.lastWorkoutDate != null) {
        final lastWorkoutDay = DateTime(progress.lastWorkoutDate!.year, progress.lastWorkoutDate!.month, progress.lastWorkoutDate!.day);
        final yesterday = today.subtract(const Duration(days: 1));

        if (lastWorkoutDay.isAtSameMomentAs(yesterday)) {
          newStreak++;
        } else if (!lastWorkoutDay.isAtSameMomentAs(today)) {
          newStreak = 1;
        }
      } else {
        newStreak = 1;
      }

      final newTotal = progress.totalWorkouts + 1;
      final newLongestStreak = newStreak > progress.longestStreak ? newStreak : progress.longestStreak;

      final updatedProgress = UserProgress(
        currentStreak: newStreak,
        longestStreak: newLongestStreak,
        totalWorkouts: newTotal,
        lastWorkoutDate: now,
      );
      
      final Map<String, dynamic> updates = {'progress': updatedProgress.toMap()};
      if (planStartDate == null) {
        updates['planStartDate'] = Timestamp.fromDate(now);
      }

      transaction.update(userRef, updates);
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
  
  Future<List<Exercise>> getLocalExercises() async {
    try {
      final String response = await rootBundle.loadString('assets/data/exercises.json');
      final data = await json.decode(response) as List;
      return data.map((e) => Exercise.fromJson(e)).toList();
    } catch (e) {
      print("Error loading local exercises: $e");
      return [];
    }
  }

  Future<WorkoutPlan?> getRecommendedPlan(String goal, String level) async {
    try {
      final querySnapshot = await _db
          .collection('workoutPlans')
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
    required List<PerformedExercise> exercises,
    required String difficultyFeedback,
  }) async {
    try {
      await _db.collection('users').doc(uid).collection('workoutHistory').add({
        'planName': planName,
        'workoutName': workoutName,
        'dayCompleted': dayCompleted,
        'completedDate': FieldValue.serverTimestamp(),
        'exercises': exercises.map((e) => e.toMap()).toList(),
        'difficultyFeedback': difficultyFeedback,
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

      return snapshot.docs
          .map((doc) => WorkoutHistory.fromFirestore(doc))
          .toList();
    } catch (e) {
      print("Error fetching workout history: $e");
      return [];
    }
  }

  Future<DietPlan?> getRecommendedDietPlan(String goal) async {
    try {
      final query = await _db
          .collection('dietPlans')
          .where('goal', isEqualTo: goal)
          .limit(1)
          .get();
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
    } catch (e) {
      print("Error getting all recipes: $e");
      return [];
    }
  }

  Future<void> logMeal({
    required String uid,
    required String mealType,
    required int calories,
    required int protein,
    required int carbs,
    required int fat,
  }) async {
    final now = DateTime.now();
    final docId =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final docRef =
        _db.collection('users').doc(uid).collection('dailyProgress').doc(docId);

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);

      if (!snapshot.exists) {
        transaction.set(docRef, {
          'date': Timestamp.fromDate(now),
          'caloriesConsumed': calories,
          'proteinConsumed': protein,
          'carbsConsumed': carbs,
          'fatConsumed': fat,
          'mealsCompleted': {mealType: true},
        });
      } else {
        transaction.update(docRef, {
          'caloriesConsumed': FieldValue.increment(calories),
          'proteinConsumed': FieldValue.increment(protein),
          'carbsConsumed': FieldValue.increment(carbs),
          'fatConsumed': FieldValue.increment(fat),
          'mealsCompleted.$mealType': true,
        });
      }
    });
  }

  Future<DailyProgress> getDailyProgress(String uid) async {
    final now = DateTime.now();
    final docId =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final docRef =
        _db.collection('users').doc(uid).collection('dailyProgress').doc(docId);

    final doc = await docRef.get();
    if (doc.exists) {
      return DailyProgress.fromFirestore(doc);
    } else {
      return DailyProgress(date: now);
    }
  }
}