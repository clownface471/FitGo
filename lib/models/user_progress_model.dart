import 'package:cloud_firestore/cloud_firestore.dart';

class UserProgress {
  final int currentStreak;
  final int longestStreak;
  final int totalWorkouts;
  final DateTime? lastWorkoutDate;

  UserProgress({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalWorkouts = 0,
    this.lastWorkoutDate,
  });

  factory UserProgress.fromMap(Map<String, dynamic>? data) {
    if (data == null) {
      return UserProgress();
    }
    return UserProgress(
      currentStreak: data['currentStreak'] ?? 0,
      longestStreak: data['longestStreak'] ?? 0,
      totalWorkouts: data['totalWorkouts'] ?? 0,
      lastWorkoutDate: (data['lastWorkoutDate'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'totalWorkouts': totalWorkouts,
      'lastWorkoutDate': lastWorkoutDate != null
          ? Timestamp.fromDate(lastWorkoutDate!)
          : null,
    };
  }
}