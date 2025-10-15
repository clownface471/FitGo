import 'package:cloud_firestore/cloud_firestore.dart';

class Meal {
  final String recipeId;
  Meal({required this.recipeId});

  factory Meal.fromMap(Map<String, dynamic> map) {
    return Meal(recipeId: map['recipeId'] ?? '');
  }
}

class DailyMealPlan {
  final int day;
  final Meal breakfast;
  final Meal lunch;
  final Meal dinner;

  DailyMealPlan({
    required this.day,
    required this.breakfast,
    required this.lunch,
    required this.dinner,
  });

  factory DailyMealPlan.fromMap(Map<String, dynamic> map) {
    return DailyMealPlan(
      day: map['day'] ?? 0,
      breakfast: Meal.fromMap(map['breakfast'] ?? {}),
      lunch: Meal.fromMap(map['lunch'] ?? {}),
      dinner: Meal.fromMap(map['dinner'] ?? {}),
    );
  }
}

class DietPlan {
  final String planName;
  final String goal;
  final List<DailyMealPlan> dailyMeals;

  DietPlan({
    required this.planName,
    required this.goal,
    required this.dailyMeals,
  });

  factory DietPlan.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return DietPlan.fromMap(data); // Panggil fromMap
  }
  
  factory DietPlan.fromMap(Map<String, dynamic> map) {
    var mealList = map['dailyMeals'] as List<dynamic>? ?? [];
    return DietPlan(
      planName: map['planName'] ?? 'Unnamed Diet Plan',
      goal: map['goal'] ?? 'general',
      dailyMeals: mealList.map((m) => DailyMealPlan.fromMap(m)).toList(),
    );
  }
}