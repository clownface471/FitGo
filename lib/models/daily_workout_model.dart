class DailyExercise {
  final String exerciseId;
  final String exerciseName; // Tambahkan field ini
  final int sets;
  final String reps;

  DailyExercise({
    required this.exerciseId,
    required this.exerciseName, // Tambahkan di constructor
    required this.sets,
    required this.reps,
  });

  factory DailyExercise.fromMap(Map<String, dynamic> map) {
    return DailyExercise(
      exerciseId: map['exerciseId'] ?? '',
      exerciseName: map['exerciseName'] ?? '', // Tambahkan parsing
      sets: map['sets'] ?? 0,
      reps: map['reps'] ?? '0',
    );
  }
}

class DailyWorkout {
  final int day;
  final String workoutName;
  final List<DailyExercise> exercises;

  DailyWorkout({
    required this.day,
    required this.workoutName,
    required this.exercises,
  });

  factory DailyWorkout.fromMap(Map<String, dynamic> map) {
    var exerciseList = map['exercises'] as List<dynamic>? ?? [];
    return DailyWorkout(
      day: map['day'] ?? 0,
      workoutName: map['workoutName'] ?? 'Rest Day',
      exercises: exerciseList.map((e) => DailyExercise.fromMap(e)).toList(),
    );
  }
}