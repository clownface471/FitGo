import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DataUploader {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> uploadAllData() async {
    final exerciseNameToIdMap = await _uploadAndFetchExercises();
    await _uploadWorkoutPlans(exerciseNameToIdMap);
    
    final recipeNameToIdMap = await _uploadAndFetchRecipes();
    await _uploadDietPlans(recipeNameToIdMap);

    print("--- PROSES UNGGAH SEMUA DATA SELESAI ---");
  }

  Future<Map<String, String>> _uploadAndFetchExercises() async {
    final collectionRef = _db.collection('exercises');
    final snapshot = await collectionRef.limit(1).get();

    if (snapshot.docs.isNotEmpty) {
      print("Data latihan sudah ada. Melewatkan unggah exercises.");
    } else {
      print("Memulai unggah exercises.json...");
      final String jsonString = await rootBundle.loadString('assets/data/exercises.json');
      final List<dynamic> exercises = json.decode(jsonString);
      final WriteBatch batch = _db.batch();
      for (final exercise in exercises) {
        final docRef = collectionRef.doc();
        batch.set(docRef, exercise as Map<String, dynamic>);
      }
      await batch.commit();
      print("Unggah exercises.json selesai.");
    }

    print("Membuat pemetaan Nama Latihan ke ID...");
    final allExercisesSnapshot = await collectionRef.get();
    final Map<String, String> nameToIdMap = {};
    for (final doc in allExercisesSnapshot.docs) {
      final name = doc.data()['name'] as String?;
      if (name != null) {
        nameToIdMap[name.toLowerCase()] = doc.id; 
      }
    }
    print("Pemetaan selesai. Ditemukan ${nameToIdMap.length} latihan.");
    return nameToIdMap;
  }

  Future<void> _uploadWorkoutPlans(Map<String, String> nameToIdMap) async {
    final collectionRef = _db.collection('workoutPlans');
    final snapshot = await collectionRef.limit(1).get();

    if (snapshot.docs.isNotEmpty) {
      print("Data program latihan sudah ada. Proses unggah dibatalkan.");
      return;
    }

    print("Memulai unggah workout_plans.json...");
    final String jsonString = await rootBundle.loadString('assets/data/workout_plans.json');
    final List<dynamic> plans = json.decode(jsonString);
    final WriteBatch batch = _db.batch();

    for (final plan in plans) {
      final planData = plan as Map<String, dynamic>;
      final List<dynamic> workouts = planData['workouts'];

      for (final workout in workouts) {
        final List<dynamic> exercises = workout['exercises'];
        for (final exercise in exercises) {
          final String exerciseName = exercise['exerciseName'];
          final String? exerciseId = nameToIdMap[exerciseName.toLowerCase()];

          if (exerciseId != null) {
            exercise['exerciseId'] = exerciseId; 
          } else {
            print("PERINGATAN: Latihan bernama '$exerciseName' tidak ditemukan di database exercises.");
          }
          exercise.remove('exerciseName'); 
        }
      }

      final docRef = collectionRef.doc();
      batch.set(docRef, planData);
    }

    await batch.commit();
    print("Unggah program latihan selesai.");
  }
  Future<Map<String, String>> _uploadAndFetchRecipes() async {
    final collectionRef = _db.collection('recipes');
    if ((await collectionRef.limit(1).get()).docs.isNotEmpty) {
      print("Data resep sudah ada. Melewatkan unggah.");
    } else {
      print("Memulai unggah recipes.json...");
      final jsonString = await rootBundle.loadString('assets/data/recipes.json');
      final List<dynamic> recipes = json.decode(jsonString);
      final WriteBatch batch = _db.batch();
      for (final recipe in recipes) {
        final docRef = collectionRef.doc(recipe['recipeId']); 
        batch.set(docRef, recipe as Map<String, dynamic>);
      }
      await batch.commit();
      print("Unggah recipes.json selesai.");
    }

    final allRecipesSnapshot = await collectionRef.get();
    final Map<String, String> nameToIdMap = {};
    for (final doc in allRecipesSnapshot.docs) {
      nameToIdMap[doc.data()['name']] = doc.id;
    }
    return nameToIdMap;
  }

  Future<void> _uploadDietPlans(Map<String, String> recipeNameToIdMap) async {
    final collectionRef = _db.collection('dietPlans');
    if ((await collectionRef.limit(1).get()).docs.isNotEmpty) {
      print("Data program diet sudah ada. Dibatalkan.");
      return;
    }

    print("Memulai unggah diet_plans.json...");
    final jsonString = await rootBundle.loadString('assets/data/diet_plans.json');
    final List<dynamic> plans = json.decode(jsonString);
    final WriteBatch batch = _db.batch();

    for (final plan in plans) {
      final docRef = collectionRef.doc();
      batch.set(docRef, plan as Map<String, dynamic>);
    }
    await batch.commit();
    print("Unggah diet_plans.json selesai.");
  }
}