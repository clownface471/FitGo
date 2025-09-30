import 'package:cloud_firestore/cloud_firestore.dart';

class WorkoutHistory {
  final String id;
  final String planName;
  final String workoutName;
  final DateTime completedDate;
  final int dayCompleted;

  WorkoutHistory({
    required this.id,
    required this.planName,
    required this.workoutName,
    required this.completedDate,
    required this.dayCompleted,
  });

  factory WorkoutHistory.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return WorkoutHistory(
      id: doc.id,
      planName: data['planName'] ?? 'Nama Program Tidak Ada',
      workoutName: data['workoutName'] ?? 'Nama Latihan Tidak Ada',
      completedDate: (data['completedDate'] as Timestamp).toDate(),
      dayCompleted: data['dayCompleted'] ?? 0,
    );
  }
}