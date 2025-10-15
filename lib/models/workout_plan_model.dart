import 'package:cloud_firestore/cloud_firestore.dart';
import 'daily_workout_model.dart';

class WorkoutPlan {
  final String planName;
  final String level;
  final String goal;
  final int durationDays;
  final List<DailyWorkout> workouts;

  WorkoutPlan({
    required this.planName,
    required this.level,
    required this.goal,
    required this.durationDays,
    required this.workouts,
  });

  factory WorkoutPlan.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return WorkoutPlan.fromMap(data); 
  }

  factory WorkoutPlan.fromMap(Map<String, dynamic> map) {
    var workoutList = map['workouts'] as List<dynamic>? ?? [];
    return WorkoutPlan(
      planName: map['planName'] ?? 'Unnamed Plan',
      level: map['level'] ?? 'beginner',
      goal: map['goal'] ?? 'general',
      durationDays: map['durationDays'] ?? 0,
      workouts: workoutList.map((w) => DailyWorkout.fromMap(w)).toList(),
    );
  }
}