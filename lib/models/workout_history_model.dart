import 'package:cloud_firestore/cloud_firestore.dart';
import 'performed_set_model.dart';

class PerformedExercise {
  final String exerciseId;
  final String exerciseName;
  final List<PerformedSet> sets;

  PerformedExercise({required this.exerciseId, required this.exerciseName, required this.sets});

  Map<String, dynamic> toMap() {
    return {
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'sets': sets.map((s) => s.toMap()).toList(),
    };
  }
  
  factory PerformedExercise.fromMap(Map<String, dynamic> map) {
    return PerformedExercise(
      exerciseId: map['exerciseId'] ?? '',
      exerciseName: map['exerciseName'] ?? '',
      sets: (map['sets'] as List<dynamic>? ?? []).map((s) => PerformedSet.fromMap(s)).toList(),
    );
  }
}

class WorkoutHistory {
  final String id;
  final String planName;
  final String workoutName;
  final DateTime completedDate;
  final int dayCompleted;
  final List<PerformedExercise> exercises;
  final String? difficultyFeedback;

  WorkoutHistory({
    required this.id,
    required this.planName,
    required this.workoutName,
    required this.completedDate,
    required this.dayCompleted,
    required this.exercises,
    this.difficultyFeedback,
  });

  factory WorkoutHistory.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return WorkoutHistory(
      id: doc.id,
      planName: data['planName'] ?? 'N/A',
      workoutName: data['workoutName'] ?? 'N/A',
      completedDate: (data['completedDate'] as Timestamp).toDate(),
      dayCompleted: data['dayCompleted'] ?? 0,
      exercises: (data['exercises'] as List<dynamic>? ?? []).map((e) => PerformedExercise.fromMap(e)).toList(),
      difficultyFeedback: data['difficultyFeedback'] as String?,
    );
  }
}