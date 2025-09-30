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
      breakfast: Meal.fromMap(map['meals']['breakfast']),
      lunch: Meal.fromMap(map['meals']['lunch']),
      dinner: Meal.fromMap(map['meals']['dinner']),
    );
  }
}

class DietPlan {
  final String id;
  final String planName;
  final String goal;
  final List<DailyMealPlan> dailyMeals;

  DietPlan({
    required this.id,
    required this.planName,
    required this.goal,
    required this.dailyMeals,
  });

  factory DietPlan.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    var mealList = data['dailyMeals'] as List<dynamic>? ?? [];
    return DietPlan(
      id: doc.id,
      planName: data['planName'] ?? '',
      goal: data['goal'] ?? '',
      dailyMeals: mealList.map((m) => DailyMealPlan.fromMap(m)).toList(),
    );
  }
}