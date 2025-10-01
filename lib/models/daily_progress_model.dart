import 'package:cloud_firestore/cloud_firestore.dart';

class DailyProgress {
  final DateTime date;
  final int caloriesConsumed;
  final int proteinConsumed;
  final int carbsConsumed;
  final int fatConsumed;
  final bool breakfastCompleted;
  final bool lunchCompleted;
  final bool dinnerCompleted;

  DailyProgress({
    required this.date,
    this.caloriesConsumed = 0,
    this.proteinConsumed = 0,
    this.carbsConsumed = 0,
    this.fatConsumed = 0,
    this.breakfastCompleted = false,
    this.lunchCompleted = false,
    this.dinnerCompleted = false,
  });

  factory DailyProgress.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};
    Map<String, dynamic> meals = data['mealsCompleted'] as Map<String, dynamic>? ?? {};
    
    return DailyProgress(
      date: (data['date'] as Timestamp? ?? Timestamp.now()).toDate(),
      caloriesConsumed: data['caloriesConsumed'] ?? 0,
      proteinConsumed: data['proteinConsumed'] ?? 0,
      carbsConsumed: data['carbsConsumed'] ?? 0,
      fatConsumed: data['fatConsumed'] ?? 0,
      breakfastCompleted: meals['breakfast'] ?? false,
      lunchCompleted: meals['lunch'] ?? false,
      dinnerCompleted: meals['dinner'] ?? false,
    );
  }
}