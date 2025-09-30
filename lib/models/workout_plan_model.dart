import 'package:cloud_firestore/cloud_firestore.dart';
import 'daily_workout_model.dart';

class WorkoutPlan {
  final String id;
  final String planName;
  final String level;
  final String goal;
  final int durationDays;
  final List<DailyWorkout> workouts;

  WorkoutPlan({
    required this.id,
    required this.planName,
    required this.level,
    required this.goal,
    required this.durationDays,
    required this.workouts,
  });

  factory WorkoutPlan.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    var workoutList = data['workouts'] as List<dynamic>? ?? [];
    return WorkoutPlan(
      id: doc.id,
      planName: data['planName'] ?? 'Unnamed Plan',
      level: data['level'] ?? 'N/A',
      goal: data['goal'] ?? 'N/A',
      durationDays: data['durationDays'] ?? 0,
      workouts: workoutList.map((w) => DailyWorkout.fromMap(w)).toList(),
    );
  }
}